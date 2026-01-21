import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type PushStatus =
  | "confirmed"
  | "preparing"
  | "out_for_delivery"
  | "ready"
  | "delivered"
  | "canceled";

type OrderPushPayload = {
  userId: string;
  orderId: string;
  orderNumber?: string;
  status: PushStatus;
  progress?: number;
  fulfillmentType?: "delivery" | "pickup";
  etaMinutes?: number;
  title?: string;
  subtitle?: string;
  icon?: string;
  deeplink?: string;
};

type OrderStatusPushInput = {
  orderId: string;
  orderNumber?: string | null;
  status: string;
  fulfillmentType?: "delivery" | "pickup" | null;
  etaIso?: string | null;
  userId?: string | null;
  customerId?: string | null;
};

const ONESIGNAL_APP_ID = Deno.env.get("ONESIGNAL_APP_ID");
const ONESIGNAL_REST_API_KEY = Deno.env.get("ONESIGNAL_REST_API_KEY");
const ONESIGNAL_ANDROID_CHANNEL_ID = Deno.env.get("ONESIGNAL_ANDROID_CHANNEL_ID");

const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

const supabase = SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY
  ? createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
  : null;

const PUSH_STATUS_SET = new Set<PushStatus>([
  "confirmed",
  "preparing",
  "out_for_delivery",
  "ready",
  "delivered",
  "canceled",
]);

const STATUS_ALIAS_MAP: Record<string, { status: PushStatus; progress?: number }> = {
  created: { status: "confirmed", progress: 0.1 },
  accepted: { status: "confirmed", progress: 0.2 },
  in_kitchen: { status: "preparing", progress: 0.5 },
  courier_requested: { status: "preparing", progress: 0.6 },
  driver_en_route: { status: "out_for_delivery", progress: 0.75 },
  driver_assigned: { status: "out_for_delivery", progress: 0.75 },
  picked_up: { status: "out_for_delivery", progress: 0.85 },
  ready: { status: "ready", progress: 0.8 },
  delivered: { status: "delivered", progress: 1.0 },
  canceled: { status: "canceled", progress: 1.0 },
  rejected: { status: "canceled", progress: 1.0 },
  failed: { status: "canceled", progress: 1.0 },
};

const statusLabel = (status: PushStatus) => {
  switch (status) {
    case "confirmed":
      return "Confirmed";
    case "preparing":
      return "Preparing";
    case "out_for_delivery":
      return "Out for delivery";
    case "ready":
      return "Ready";
    case "delivered":
      return "Delivered";
    case "canceled":
      return "Canceled";
    default:
      return "Updated";
  }
};

const fallbackProgress = (status: PushStatus) => {
  switch (status) {
    case "confirmed":
      return 0.2;
    case "preparing":
      return 0.5;
    case "out_for_delivery":
      return 0.8;
    case "ready":
      return 0.8;
    case "delivered":
      return 1.0;
    case "canceled":
      return 1.0;
    default:
      return 0.1;
  }
};

const resolvePushStatus = (status?: string | null): { status: PushStatus; progress?: number } | null => {
  if (!status) return null;
  const normalized = status.toLowerCase();
  if (PUSH_STATUS_SET.has(normalized as PushStatus)) {
    return { status: normalized as PushStatus };
  }
  return STATUS_ALIAS_MAP[normalized] ?? null;
};

const computeEtaMinutes = (etaIso?: string | null): number | undefined => {
  if (!etaIso) return undefined;
  const etaMs = Date.parse(etaIso);
  if (Number.isNaN(etaMs)) return undefined;
  return Math.max(0, Math.round((etaMs - Date.now()) / 60000));
};

const resolveCustomerAuthUserId = async (customerId?: string | null): Promise<string | null> => {
  if (!customerId || !supabase) return null;
  const { data } = await supabase
    .from("customers")
    .select("auth_user_id")
    .eq("id", customerId)
    .maybeSingle();
  return data?.auth_user_id ?? null;
};

const getSubscriptionIds = async (userId: string) => {
  if (!supabase) return [] as string[];
  const { data, error } = await supabase
    .from("push_tokens")
    .select("subscription_id")
    .eq("user_id", userId);
  if (error) {
    console.warn("⚠️ Failed to load push subscriptions", error);
    return [];
  }
  return (data ?? [])
    .map((row) => row.subscription_id)
    .filter((id): id is string => Boolean(id));
};

export const sendOrderStatusPush = async (payload: OrderPushPayload): Promise<void> => {
  if (!ONESIGNAL_APP_ID || !ONESIGNAL_REST_API_KEY) {
    throw new Error("Missing OneSignal secrets");
  }

  const progress = typeof payload.progress === "number"
    ? payload.progress
    : fallbackProgress(payload.status);

  const heading = payload.title || "Order update";
  const subtitle = payload.subtitle || (payload.orderNumber ? `Order #${payload.orderNumber}` : "Order update");

  const data = {
    orderId: payload.orderId,
    order_id: payload.orderId,
    orderNumber: payload.orderNumber,
    order_number: payload.orderNumber,
    status: payload.status,
    progress,
    fulfillmentType: payload.fulfillmentType,
    etaMinutes: payload.etaMinutes,
    title: heading,
    subtitle,
    icon: payload.icon,
    deeplink: payload.deeplink || `shahirizada://orders/${payload.orderId}`,
  };

  const includeExternalUserIds = payload.userId ? [payload.userId] : [];
  const includeSubscriptionIds = payload.userId
    ? await getSubscriptionIds(payload.userId)
    : [];

  const body: Record<string, unknown> = {
    app_id: ONESIGNAL_APP_ID,
    target_channel: "push",
    headings: { en: heading },
    contents: { en: `Order ${statusLabel(payload.status)}` },
    data,
    ios_badgeType: "Increase",
    ios_badgeCount: 1,
  };

  if (ONESIGNAL_ANDROID_CHANNEL_ID) {
    body.android_channel_id = ONESIGNAL_ANDROID_CHANNEL_ID;
  }

  if (includeExternalUserIds.length) {
    body.include_external_user_ids = includeExternalUserIds;
    body.channel_for_external_user_ids = "push";
  } else if (includeSubscriptionIds.length) {
    body.include_subscription_ids = includeSubscriptionIds;
  } else {
    console.log(`Push skipped: no target ids for order ${payload.orderId}`);
    return;
  }

  const response = await fetch("https://api.onesignal.com/notifications", {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      Authorization: `Key ${ONESIGNAL_REST_API_KEY}`,
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`OneSignal error: ${response.status} ${text}`);
  }
};

export const sendOrderStatusPushForOrder = async (
  input: OrderStatusPushInput
): Promise<void> => {
  const resolvedStatus = resolvePushStatus(input.status);
  if (!resolvedStatus) {
    console.log(`Push skipped: unsupported status "${input.status}"`);
    return;
  }

  const userId = input.userId || await resolveCustomerAuthUserId(input.customerId);
  if (!userId) {
    console.log(`Push skipped: missing userId for order ${input.orderId}`);
    return;
  }

  const etaMinutes = computeEtaMinutes(input.etaIso);

  await sendOrderStatusPush({
    userId,
    orderId: input.orderId,
    orderNumber: input.orderNumber ?? undefined,
    status: resolvedStatus.status,
    progress: resolvedStatus.progress,
    fulfillmentType: input.fulfillmentType ?? undefined,
    etaMinutes,
  });
};
