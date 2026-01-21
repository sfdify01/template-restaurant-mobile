# Order Status Notifications + Live Activity Guide (Supabase Edge Functions)

This guide explains how to send order status push notifications from Supabase Edge Functions and how those pushes drive Live Activities (iOS lock screen + Dynamic Island) and Android live activity notifications in the Flutter app.

## Overview

High-level flow:

1. Flutter app registers with OneSignal and logs in with External ID (Supabase user ID).
2. Flutter app starts a Live Activity and registers its token with OneSignal via `enterLiveActivity(orderId, token)`.
3. Edge function updates order status in the database.
4. Edge function sends **TWO** types of notifications:
   - **Regular push notification** - For in-app updates and notification tray
   - **Live Activity update** - Sent via OneSignal's Live Activities API to update the lock screen widget

## CRITICAL: How Live Activities Work in Background

**Live Activities can ONLY be updated when the app is closed via APNs push notifications sent directly to the activity token.**

The previous approach of sending regular push notifications and having the app update the Live Activity **does NOT work** when the app is in the background or closed, because:
- Regular push notifications require the app to process them
- When the app is closed, it cannot process notifications
- iOS Live Activities require a special APNs push type (`liveactivity`) sent to the activity's push token

**Solution**: Use OneSignal's Live Activities API to send updates directly to the activity token. This bypasses the app entirely and updates the widget directly via APNs.

## Required Secrets (Supabase Edge Functions)

Add these secrets in both test and production projects (see `SUPABASE_SECRETS_SETUP.md` for how to set them):

- `ONESIGNAL_APP_ID`
- `ONESIGNAL_REST_API_KEY`
- `ONESIGNAL_ANDROID_CHANNEL_ID` (optional, if you use custom Android channels)

If you query `public.push_tokens` inside edge functions:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

## Expected Push Payload (Contract)

The Flutter app listens for order updates with these keys in the push `data` object.

Required (camelCase or snake_case are both accepted in the app):
- `orderId` / `order_id` (string)
- `status` (string: `confirmed`, `preparing`, `out_for_delivery`, `ready`, `delivered`, `canceled`)

Recommended (optional):
- `orderNumber` / `order_number` (string)
- `progress` (number 0.0-1.0)
- `fulfillmentType` (string: `delivery` or `pickup`)
- `etaMinutes` (number)
- `title` (string)
- `subtitle` (string)
- `icon` (string; asset name or URL)
- `deeplink` (string; app route like `shahirizada://orders/<id>`)

If `progress` is not provided, the app will use a fallback based on `status`.

## Database Table: `public.push_tokens`

The Flutter app stores push metadata here so Edge Functions can use it as a fallback.

Expected columns:
- `id` uuid
- `user_id` uuid
- `subscription_id` text
- `push_token` text
- `platform` text
- `created_at` timestamptz
- `updated_at` timestamptz

RLS should allow the user to upsert their own token and deny cross-user access.

## Edge Function Helper (OneSignal)

Add a helper to `supabase/functions/market-server` (for example `notifications.ts`) and call it from any route that changes order status.

**IMPORTANT**: You must send BOTH a regular push notification AND a Live Activity update for full functionality:
- Regular push: Shows in notification tray, updates app if in foreground
- Live Activity update: Updates lock screen widget even when app is closed

```ts
// supabase/functions/market-server/notifications.ts
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type OrderPushPayload = {
  userId: string;
  orderId: string;
  orderNumber?: string;
  status: string;
  progress?: number;
  fulfillmentType?: "delivery" | "pickup";
  etaMinutes?: number;
  eta?: string; // ISO 8601 date string
};

const ONESIGNAL_APP_ID = Deno.env.get("ONESIGNAL_APP_ID");
const ONESIGNAL_REST_API_KEY = Deno.env.get("ONESIGNAL_REST_API_KEY");
const ONESIGNAL_ANDROID_CHANNEL_ID = Deno.env.get("ONESIGNAL_ANDROID_CHANNEL_ID");

const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

const supabase = SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY
  ? createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
  : null;

const statusLabel = (status: string) => {
  switch (status) {
    case "created":
      return "Order Placed";
    case "confirmed":
    case "accepted":
      return "Order Confirmed";
    case "preparing":
    case "in_kitchen":
      return "Preparing";
    case "ready":
      return "Ready";
    case "courier_requested":
      return "Finding Driver";
    case "driver_en_route":
      return "Driver En Route";
    case "picked_up":
    case "out_for_delivery":
      return "Out for Delivery";
    case "delivered":
      return "Delivered";
    case "canceled":
    case "cancelled":
      return "Cancelled";
    default:
      return "Updated";
  }
};

const fallbackProgress = (status: string, isDelivery: boolean) => {
  if (isDelivery) {
    switch (status) {
      case "created": return 0.1;
      case "confirmed":
      case "accepted": return 0.2;
      case "preparing":
      case "in_kitchen": return 0.35;
      case "ready": return 0.5;
      case "courier_requested": return 0.6;
      case "driver_en_route": return 0.7;
      case "picked_up":
      case "out_for_delivery": return 0.85;
      case "delivered": return 1.0;
      case "canceled":
      case "cancelled": return 1.0;
      default: return 0.1;
    }
  } else {
    switch (status) {
      case "created": return 0.1;
      case "confirmed":
      case "accepted": return 0.25;
      case "preparing":
      case "in_kitchen": return 0.5;
      case "ready": return 0.85;
      case "delivered": return 1.0;
      case "canceled":
      case "cancelled": return 1.0;
      default: return 0.1;
    }
  }
};

const getSubscriptionIds = async (userId: string) => {
  if (!supabase) return [] as string[];
  const { data } = await supabase
    .from("push_tokens")
    .select("subscription_id")
    .eq("user_id", userId);
  return (data ?? [])
    .map((row) => row.subscription_id)
    .filter((id): id is string => Boolean(id));
};

/**
 * Send a regular push notification to the user.
 * This shows in the notification tray and updates the app if in foreground.
 */
export const sendOrderStatusPush = async (payload: OrderPushPayload) => {
  if (!ONESIGNAL_APP_ID || !ONESIGNAL_REST_API_KEY) {
    throw new Error("Missing OneSignal secrets");
  }

  const isDelivery = payload.fulfillmentType === "delivery";
  const progress = typeof payload.progress === "number"
    ? payload.progress
    : fallbackProgress(payload.status, isDelivery);

  const data = {
    orderId: payload.orderId,
    order_id: payload.orderId,
    orderNumber: payload.orderNumber,
    order_number: payload.orderNumber,
    status: payload.status,
    progress,
    fulfillmentType: payload.fulfillmentType,
    etaMinutes: payload.etaMinutes,
    title: "Order update",
    subtitle: payload.orderNumber
      ? `Order #${payload.orderNumber}`
      : "Order update",
    deeplink: `shahirizada://orders/${payload.orderId}`,
  };

  const includeExternalUserIds = [payload.userId];
  const includeSubscriptionIds = await getSubscriptionIds(payload.userId);

  const body: Record<string, unknown> = {
    app_id: ONESIGNAL_APP_ID,
    target_channel: "push",
    headings: { en: "Order update" },
    contents: { en: `Order ${statusLabel(payload.status)}` },
    data,
    ios_badgeType: "Increase",
    ios_badgeCount: 1,
  };

  if (ONESIGNAL_ANDROID_CHANNEL_ID) {
    body.android_channel_id = ONESIGNAL_ANDROID_CHANNEL_ID;
  }

  // Prefer External IDs, fallback to player IDs if needed.
  if (includeExternalUserIds.length) {
    body.include_external_user_ids = includeExternalUserIds;
    body.channel_for_external_user_ids = "push";
  } else if (includeSubscriptionIds.length) {
    body.include_subscription_ids = includeSubscriptionIds;
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
    throw new Error(`OneSignal push error: ${response.status} ${text}`);
  }
};

/**
 * Update an iOS Live Activity via OneSignal's Live Activities API.
 * 
 * CRITICAL: This is what makes Live Activities update when the app is closed!
 * 
 * The activity_id is the orderId that was used when starting the activity
 * via `OneSignal.LiveActivities.enterLiveActivity(orderId, token)` in the app.
 * 
 * The event payload must match the ContentState structure in the iOS widget:
 * - status: string
 * - statusLabel: string  
 * - progress: number (0.0 - 1.0)
 * - eta: string (optional, formatted like "15 min" or "2:30 PM")
 * - fulfillment: string ("Delivery" or "Pickup")
 */
export const updateLiveActivity = async (payload: OrderPushPayload) => {
  if (!ONESIGNAL_APP_ID || !ONESIGNAL_REST_API_KEY) {
    throw new Error("Missing OneSignal secrets");
  }

  const isDelivery = payload.fulfillmentType === "delivery";
  const progress = typeof payload.progress === "number"
    ? payload.progress
    : fallbackProgress(payload.status, isDelivery);

  // Format ETA for display
  let etaDisplay: string | undefined;
  if (payload.eta) {
    try {
      const etaDate = new Date(payload.eta);
      const now = new Date();
      const diffMinutes = Math.round((etaDate.getTime() - now.getTime()) / 60000);
      
      if (diffMinutes <= 1) {
        etaDisplay = isDelivery ? "Arriving" : "Ready";
      } else if (diffMinutes < 60) {
        etaDisplay = `${diffMinutes} min`;
      } else {
        // Format as time like "2:30 PM"
        etaDisplay = etaDate.toLocaleTimeString("en-US", { 
          hour: "numeric", 
          minute: "2-digit",
          hour12: true 
        });
      }
    } catch {
      // If parsing fails, use etaMinutes if available
      if (payload.etaMinutes) {
        etaDisplay = `${payload.etaMinutes} min`;
      }
    }
  } else if (payload.etaMinutes) {
    etaDisplay = `${payload.etaMinutes} min`;
  }

  // ContentState must match the iOS widget's OrderLiveActivityAttributes.ContentState
  const contentState = {
    status: payload.status,
    statusLabel: statusLabel(payload.status),
    progress,
    eta: etaDisplay,
    fulfillment: isDelivery ? "Delivery" : "Pickup",
  };

  // Determine the event type
  // Use "end" for terminal statuses to dismiss the Live Activity
  const isTerminal = ["delivered", "canceled", "cancelled"].includes(payload.status);
  const event = isTerminal ? "end" : "update";

  const body = {
    app_id: ONESIGNAL_APP_ID,
    activity_id: payload.orderId, // This must match the ID used in enterLiveActivity()
    event,
    event_updates: contentState,
    // For "end" events, you can specify a dismissal policy
    ...(isTerminal && { 
      dismissal_date: new Date(Date.now() + 5000).toISOString() // Dismiss after 5 seconds
    }),
  };

  console.log("[LiveActivity] Sending update:", JSON.stringify(body, null, 2));

  const response = await fetch(
    `https://api.onesignal.com/apps/${ONESIGNAL_APP_ID}/live_activities/${payload.orderId}/notifications`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        Authorization: `Key ${ONESIGNAL_REST_API_KEY}`,
      },
      body: JSON.stringify(body),
    }
  );

  if (!response.ok) {
    const text = await response.text();
    // Log but don't throw - Live Activity might not exist yet
    console.error(`[LiveActivity] Update failed: ${response.status} ${text}`);
    return;
  }

  console.log("[LiveActivity] Update sent successfully for order:", payload.orderId);
};

/**
 * Send both regular push notification AND Live Activity update.
 * Call this whenever an order status changes.
 */
export const sendOrderStatusNotification = async (payload: OrderPushPayload) => {
  // Send both in parallel for maximum speed
  await Promise.allSettled([
    sendOrderStatusPush(payload),
    updateLiveActivity(payload),
  ]);
};
```

## Where to Call It

Call `sendOrderStatusNotification` anywhere you update an order status in edge functions.

Typical candidates:
- `supabase/functions/market-server/index.ts` order status handlers
- `supabase/functions/pickup-status-updater` when pickup status changes
- Any webhook handler that changes `orders.status`

Example usage:

```ts
import { sendOrderStatusNotification } from "./notifications.ts";

// Call this whenever order status changes
await sendOrderStatusNotification({
  userId: order.customer_id,
  orderId: order.id,
  orderNumber: order.order_number,
  status: order.status, // e.g., "preparing", "ready", "delivered"
  fulfillmentType: order.fulfillment_type, // "delivery" or "pickup"
  eta: order.delivery_eta, // ISO 8601 date string
});
```

## Live Activity Behavior

### How It Works Now (Background-Safe)

1. **App starts Live Activity**: When a user places an order, the app creates a Live Activity and registers its push token with OneSignal using `enterLiveActivity(orderId, token)`.

2. **Backend sends Live Activity update**: When order status changes, call `updateLiveActivity()` which sends an APNs push directly to the activity token via OneSignal's Live Activities API.

3. **iOS updates widget directly**: iOS receives the APNs push and updates the Live Activity widget - **no app code runs**. This works even when the app is closed or killed.

4. **Terminal states end the activity**: When status is `delivered` or `canceled`, the Live Activity is dismissed after 5 seconds.

### ContentState Structure

The Live Activity update payload must match the iOS widget's `ContentState`:

```swift
public struct ContentState: Codable, Hashable {
  public var status: String        // e.g., "preparing"
  public var statusLabel: String   // e.g., "Preparing"
  public var progress: Double      // 0.0 - 1.0
  public var eta: String?          // e.g., "15 min" or "2:30 PM"
  public var fulfillment: String   // "Delivery" or "Pickup"
}
```

## Testing

### Testing Regular Push Notifications

1. Confirm the mobile app is logged into OneSignal with External ID (Supabase user ID).
2. Update an order status through the edge function.
3. Verify in OneSignal dashboard -> Delivery -> Sent Messages.

```bash
# Test regular push notification
curl -X POST https://api.onesignal.com/notifications \
  -H "Content-Type: application/json; charset=utf-8" \
  -H "Authorization: Key YOUR_ONESIGNAL_REST_API_KEY" \
  -d '{
    "app_id": "YOUR_ONESIGNAL_APP_ID",
    "target_channel": "push",
    "include_external_user_ids": ["USER_ID"],
    "channel_for_external_user_ids": "push",
    "headings": {"en": "Order update"},
    "contents": {"en": "Order preparing"},
    "data": {
      "orderId": "ORDER_ID",
      "status": "preparing"
    }
  }'
```

### Testing Live Activity Updates (Background-Safe)

**This is the critical test for background updates!**

1. Start a Live Activity in the app by placing an order
2. **Force close the app completely** (swipe up from app switcher)
3. Send a Live Activity update via curl:

```bash
# Test Live Activity update (works when app is closed!)
curl -X POST "https://api.onesignal.com/apps/YOUR_ONESIGNAL_APP_ID/live_activities/ORDER_ID/notifications" \
  -H "Content-Type: application/json; charset=utf-8" \
  -H "Authorization: Key YOUR_ONESIGNAL_REST_API_KEY" \
  -d '{
    "app_id": "YOUR_ONESIGNAL_APP_ID",
    "activity_id": "ORDER_ID",
    "event": "update",
    "event_updates": {
      "status": "preparing",
      "statusLabel": "Preparing",
      "progress": 0.5,
      "eta": "15 min",
      "fulfillment": "Delivery"
    }
  }'
```

4. Verify the Live Activity updates on the lock screen / Dynamic Island **without opening the app**

### Testing Live Activity End (Terminal Status)

```bash
# End Live Activity (for delivered/canceled orders)
curl -X POST "https://api.onesignal.com/apps/YOUR_ONESIGNAL_APP_ID/live_activities/ORDER_ID/notifications" \
  -H "Content-Type: application/json; charset=utf-8" \
  -H "Authorization: Key YOUR_ONESIGNAL_REST_API_KEY" \
  -d '{
    "app_id": "YOUR_ONESIGNAL_APP_ID",
    "activity_id": "ORDER_ID",
    "event": "end",
    "event_updates": {
      "status": "delivered",
      "statusLabel": "Delivered",
      "progress": 1.0,
      "fulfillment": "Delivery"
    },
    "dismissal_date": "2025-01-01T00:00:00Z"
  }'
```

## Troubleshooting

### Regular Push Issues
- **No push received**: Verify `ONESIGNAL_APP_ID` and `ONESIGNAL_REST_API_KEY` are set and function was redeployed.
- **External ID not found**: Ensure the app calls `OneSignal.login(userId)` after Supabase auth.

### Live Activity Issues

- **Live Activity not updating when app is closed**:
  1. Ensure `OneSignal.LiveActivities.setupDefault()` is called on app init (in `live_activity_service.dart`)
  2. Ensure backend uses `updateLiveActivity()` to send via Live Activities API, not regular push
  3. Verify the `activity_id` matches the `orderId` used in `enterLiveActivity(orderId, token)`

- **Live Activity not starting**:
  1. Check device is iOS 16.1+
  2. Verify Live Activities are enabled in Settings > Shahirizada > Live Activities
  3. Check console logs for `[LiveActivity]` messages

- **"Activity not found" error from OneSignal**:
  1. The Live Activity wasn't started yet, or was ended
  2. The `activity_id` doesn't match what was registered with `enterLiveActivity()`
  3. The activity token wasn't properly registered with OneSignal

- **ContentState decode error**:
  1. The `event_updates` payload doesn't match the iOS widget's `ContentState` structure
  2. Check that all required fields are present: `status`, `statusLabel`, `progress`, `fulfillment`

### Debug Commands

```bash
# Check if Live Activity is registered with OneSignal
# Look in OneSignal dashboard: Users > [User] > Live Activities

# Check iOS console logs (via Xcode or Console.app)
# Filter by: "LiveActivity" or "ActivityKit"
```

## Environment Summary

| Environment | Supabase Project | Edge Function URL |
| --- | --- | --- |
| Test | `pbzpqsdjaiynrpjpubai` | `https://pbzpqsdjaiynrpjpubai.supabase.co/functions/v1/market-server` |
| Production | `cdfllxxtgguyveowmdis` | `https://cdfllxxtgguyveowmdis.supabase.co/functions/v1/market-server` |
