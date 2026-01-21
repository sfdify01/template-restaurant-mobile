import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Order Live Activity Attributes

@available(iOS 16.1, *)
public struct OrderLiveActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    public var status: String
    public var statusLabel: String
    public var progress: Double
    public var eta: String?
    public var fulfillment: String

    public init(
      status: String = "confirmed",
      statusLabel: String = "Order Confirmed",
      progress: Double = 0.1,
      eta: String? = nil,
      fulfillment: String = "Delivery"
    ) {
      self.status = status
      self.statusLabel = statusLabel
      self.progress = progress
      self.eta = eta
      self.fulfillment = fulfillment
    }
  }

  public var orderId: String
  public var orderNumber: String
  public var brandName: String

  public init(
    orderId: String,
    orderNumber: String,
    brandName: String = "Shahirizada"
  ) {
    self.orderId = orderId
    self.orderNumber = orderNumber
    self.brandName = brandName
  }
}

// MARK: - Helper Extensions

@available(iOS 16.1, *)
extension OrderLiveActivityAttributes.ContentState {
  var progressPercent: Int {
    Int(min(max(progress, 0.0), 1.0) * 100)
  }

  var clampedProgress: Double {
    min(max(progress, 0.0), 1.0)
  }

  var isDelivery: Bool {
    fulfillment.lowercased().contains("delivery")
  }

  var statusIcon: String {
    switch status.lowercased() {
    case "created", "pending":
      return "checkmark.circle.fill"
    case "confirmed", "accepted":
      return "checkmark.seal.fill"
    case "preparing", "in_kitchen":
      return "flame.fill"
    case "ready":
      return "bag.fill"
    case "courier_requested", "courier_assigned", "driver_en_route":
      return "figure.walk"
    case "picked_up", "out_for_delivery":
      return "car.fill"
    case "delivered", "completed":
      return "house.fill"
    case "cancelled", "canceled":
      return "xmark.circle.fill"
    default:
      return "circle.fill"
    }
  }

  /// Format ETA string - handles ISO dates and simple strings
  var formattedEta: String? {
    guard let eta = eta, !eta.isEmpty else { return nil }

    // If it's already a simple string like "15 min" or "Ready", return as-is
    if !eta.contains("T") && !eta.contains("-") {
      return eta
    }

    // Try to parse ISO 8601 date
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    var date: Date?
    date = isoFormatter.date(from: eta)

    // Try without fractional seconds
    if date == nil {
      isoFormatter.formatOptions = [.withInternetDateTime]
      date = isoFormatter.date(from: eta)
    }

    guard let parsedDate = date else {
      // Return cleaned up version if parsing fails
      return eta.components(separatedBy: "T").first ?? eta
    }

    let now = Date()
    let diff = parsedDate.timeIntervalSince(now)

    // If in the past or very close, show "Now"
    if diff < 60 {
      return isDelivery ? "Arriving" : "Ready"
    }

    // Less than 60 minutes - show minutes
    if diff < 3600 {
      let mins = Int(diff / 60)
      return isDelivery ? "\(mins) min" : "~\(mins) min"
    }

    // Show time like "2:30 PM"
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    formatter.locale = Locale(identifier: "en_US")
    return formatter.string(from: parsedDate)
  }
}

// MARK: - Brand Colors (Shahirizada)

@available(iOS 16.1, *)
private struct BrandColors {
  // Primary - Deep burgundy (premium meat market feel)
  static let primary = Color(red: 0.42, green: 0.06, blue: 0.10)        // #6B0F1A
  static let primaryLight = Color(red: 0.545, green: 0.125, blue: 0.19) // #8B2030

  // Accent - Warm cream (Middle Eastern heritage)
  static let cream = Color(red: 0.91, green: 0.84, blue: 0.73)          // #E8D5BA
  static let gold = Color(red: 0.83, green: 0.66, blue: 0.33)           // #D4A855

  // Backgrounds
  static let backgroundDark = Color(red: 0.059, green: 0.059, blue: 0.059)  // #0F0F0F
  static let surfaceDark = Color(red: 0.102, green: 0.102, blue: 0.102)     // #1A1A1A

  // Text
  static let textPrimary = Color.white
  static let textSecondary = Color(white: 0.7)
  static let textMuted = Color(white: 0.5)
}

// MARK: - Lock Screen Widget View

@available(iOS 16.1, *)
struct LockScreenView: View {
  let context: ActivityViewContext<OrderLiveActivityAttributes>

  var body: some View {
    HStack(spacing: 16) {
      // Left: Icon with progress ring
      ZStack {
        // Background circle
        Circle()
          .fill(BrandColors.primary.opacity(0.3))
          .frame(width: 52, height: 52)

        // Progress ring
        Circle()
          .trim(from: 0, to: context.state.clampedProgress)
          .stroke(
            BrandColors.gold,
            style: StrokeStyle(lineWidth: 3, lineCap: .round)
          )
          .frame(width: 52, height: 52)
          .rotationEffect(.degrees(-90))

        // Icon
        Image(systemName: context.state.statusIcon)
          .font(.system(size: 20, weight: .semibold))
          .foregroundColor(BrandColors.cream)
      }

      // Center: Order info
      VStack(alignment: .leading, spacing: 4) {
        // Brand & Order number
        HStack(spacing: 6) {
          Text(context.attributes.brandName)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(BrandColors.textMuted)

          Text("•")
            .foregroundColor(BrandColors.textMuted)
            .font(.system(size: 10))

          Text(context.attributes.orderNumber)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(BrandColors.gold)
        }

        // Status
        Text(context.state.statusLabel)
          .font(.system(size: 16, weight: .semibold))
          .foregroundColor(BrandColors.textPrimary)

        // Fulfillment type
        Text(context.state.fulfillment)
          .font(.system(size: 12, weight: .medium))
          .foregroundColor(BrandColors.textSecondary)
      }

      Spacer()

      // Right: ETA or Progress
      VStack(alignment: .trailing, spacing: 4) {
        if let eta = context.state.formattedEta {
          Text(eta)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundColor(BrandColors.cream)

          Text(context.state.isDelivery ? "ETA" : "Ready")
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(BrandColors.textMuted)
            .textCase(.uppercase)
        } else {
          Text("\(context.state.progressPercent)%")
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundColor(BrandColors.cream)
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
  }
}

// MARK: - Dynamic Island Expanded View

@available(iOS 16.1, *)
struct ExpandedLeadingView: View {
  let context: ActivityViewContext<OrderLiveActivityAttributes>

  var body: some View {
    HStack(spacing: 10) {
      // Progress ring with icon
      ZStack {
        Circle()
          .fill(BrandColors.primary.opacity(0.4))
          .frame(width: 40, height: 40)

        Circle()
          .trim(from: 0, to: context.state.clampedProgress)
          .stroke(BrandColors.gold, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
          .frame(width: 40, height: 40)
          .rotationEffect(.degrees(-90))

        Image(systemName: context.state.statusIcon)
          .font(.system(size: 16, weight: .semibold))
          .foregroundColor(BrandColors.cream)
      }

      VStack(alignment: .leading, spacing: 2) {
        Text(context.attributes.orderNumber)
          .font(.system(size: 13, weight: .bold))
          .foregroundColor(BrandColors.gold)

        Text(context.state.statusLabel)
          .font(.system(size: 11, weight: .medium))
          .foregroundColor(BrandColors.textSecondary)
          .lineLimit(1)
      }
    }
  }
}

@available(iOS 16.1, *)
struct ExpandedTrailingView: View {
  let context: ActivityViewContext<OrderLiveActivityAttributes>

  var body: some View {
    VStack(alignment: .trailing, spacing: 2) {
      if let eta = context.state.formattedEta {
        Text(eta)
          .font(.system(size: 16, weight: .bold, design: .rounded))
          .foregroundColor(BrandColors.cream)

        Text(context.state.isDelivery ? "ETA" : "Ready")
          .font(.system(size: 9, weight: .semibold))
          .foregroundColor(BrandColors.textMuted)
          .textCase(.uppercase)
      } else {
        Text("\(context.state.progressPercent)%")
          .font(.system(size: 18, weight: .bold, design: .rounded))
          .foregroundColor(BrandColors.cream)
      }
    }
  }
}

@available(iOS 16.1, *)
struct ExpandedBottomView: View {
  let context: ActivityViewContext<OrderLiveActivityAttributes>

  var body: some View {
    VStack(spacing: 8) {
      // Progress bar
      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          // Track
          RoundedRectangle(cornerRadius: 3)
            .fill(BrandColors.textMuted.opacity(0.3))
            .frame(height: 6)

          // Progress
          RoundedRectangle(cornerRadius: 3)
            .fill(
              LinearGradient(
                colors: [BrandColors.primary, BrandColors.gold],
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .frame(width: geometry.size.width * context.state.clampedProgress, height: 6)
        }
      }
      .frame(height: 6)

      // Footer
      HStack {
        Text(context.state.fulfillment)
          .font(.system(size: 11, weight: .medium))
          .foregroundColor(BrandColors.textSecondary)

        Spacer()

        Text("\(context.state.progressPercent)% complete")
          .font(.system(size: 11, weight: .semibold))
          .foregroundColor(BrandColors.gold)
      }
    }
  }
}

// MARK: - Widget Configuration

@available(iOS 16.1, *)
struct OrderLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: OrderLiveActivityAttributes.self) { context in
      // Lock Screen / Banner presentation
      LockScreenView(context: context)
        .activityBackgroundTint(BrandColors.backgroundDark)
        .activitySystemActionForegroundColor(BrandColors.gold)
        .widgetURL(URL(string: "shahirizada://order/\(context.attributes.orderId)"))

    } dynamicIsland: { context in
      DynamicIsland {
        // Expanded presentation
        DynamicIslandExpandedRegion(.leading) {
          ExpandedLeadingView(context: context)
        }

        DynamicIslandExpandedRegion(.trailing) {
          ExpandedTrailingView(context: context)
        }

        DynamicIslandExpandedRegion(.bottom) {
          ExpandedBottomView(context: context)
        }

      } compactLeading: {
        // Compact left - Icon
        ZStack {
          Circle()
            .fill(BrandColors.primary)
            .frame(width: 24, height: 24)

          Image(systemName: context.state.statusIcon)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(BrandColors.cream)
        }

      } compactTrailing: {
        // Compact right - Progress or ETA
        if let eta = context.state.formattedEta, eta.count <= 6 {
          Text(eta)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundColor(BrandColors.gold)
        } else {
          Text("\(context.state.progressPercent)%")
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundColor(BrandColors.gold)
        }

      } minimal: {
        // Minimal - just progress ring
        ZStack {
          Circle()
            .stroke(BrandColors.textMuted.opacity(0.3), lineWidth: 2)

          Circle()
            .trim(from: 0, to: context.state.clampedProgress)
            .stroke(BrandColors.gold, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .rotationEffect(.degrees(-90))

          Circle()
            .fill(BrandColors.primary)
            .padding(3)
        }
      }
      .widgetURL(URL(string: "shahirizada://order/\(context.attributes.orderId)"))
      .keylineTint(BrandColors.gold)
    }
  }
}

// MARK: - Widget Bundle

@main
struct OrderLiveActivityBundle: WidgetBundle {
  var body: some Widget {
    if #available(iOS 16.1, *) {
      OrderLiveActivity()
    }
  }
}
