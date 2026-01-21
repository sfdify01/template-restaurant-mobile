import Flutter
import UIKit
import GoogleMaps
import ActivityKit
import OneSignalFramework

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var liveActivityChannel: FlutterMethodChannel?

  // Track active activities by orderId
  private var activeActivityIds: [String: String] = [:]

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps API key
    GMSServices.provideAPIKey("AIzaSyBSszbH3-vQzvriJd8S_4c4AM3TxbIKwEs")

    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    // Setup Live Activity method channel for Flutter
    if let controller = window?.rootViewController as? FlutterViewController {
      liveActivityChannel = FlutterMethodChannel(
        name: "us.tabsy.shahirizada/live_activity",
        binaryMessenger: controller.binaryMessenger
      )

      liveActivityChannel?.setMethodCallHandler { [weak self] (call, result) in
        guard let self = self else {
          result(FlutterError(code: "UNAVAILABLE", message: "Handler unavailable", details: nil))
          return
        }

        if #available(iOS 16.2, *) {
          switch call.method {
          case "startActivity":
            self.handleStartActivity(call: call, result: result)
          case "updateActivity":
            self.handleUpdateActivity(call: call, result: result)
          case "endActivity":
            self.handleEndActivity(call: call, result: result)
          default:
            result(FlutterMethodNotImplemented)
          }
        } else {
          result(FlutterError(code: "UNSUPPORTED", message: "Live Activities require iOS 16.2+", details: nil))
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @available(iOS 16.2, *)
  private func handleStartActivity(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let orderId = args["orderId"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing orderId", details: nil))
      return
    }

    // Check if activities are enabled
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
      result(FlutterError(code: "DISABLED", message: "Live Activities are disabled", details: nil))
      return
    }

    // End any existing activity for this order
    endExistingActivity(orderId: orderId)

    let orderNumber = args["orderNumber"] as? String ?? "Order"
    let brandName = args["brandName"] as? String ?? "Shahirizada"
    let status = args["status"] as? String ?? "created"
    let statusLabel = args["statusLabel"] as? String ?? "Order Placed"
    let progress = args["progress"] as? Double ?? 0.1
    let fulfillment = args["fulfillment"] as? String ?? "Delivery"
    let eta = args["eta"] as? String

    let attributes = OrderLiveActivityAttributes(
      orderId: orderId,
      orderNumber: orderNumber,
      brandName: brandName
    )

    let contentState = OrderLiveActivityAttributes.ContentState(
      status: status,
      statusLabel: statusLabel,
      progress: progress,
      eta: eta,
      fulfillment: fulfillment
    )

    do {
      let activity = try Activity<OrderLiveActivityAttributes>.request(
        attributes: attributes,
        content: ActivityContent(state: contentState, staleDate: nil),
        pushType: .token
      )

      activeActivityIds[orderId] = activity.id

      // Get the push token for this activity
      Task {
        for await tokenData in activity.pushTokenUpdates {
          let token = tokenData.map { String(format: "%02x", $0) }.joined()

          DispatchQueue.main.async {
            result(["token": token, "activityId": activity.id])
          }
          return // Only need the first token
        }
      }

    } catch {
      result(FlutterError(code: "START_FAILED", message: error.localizedDescription, details: nil))
    }
  }

  @available(iOS 16.2, *)
  private func handleUpdateActivity(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let orderId = args["orderId"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing orderId", details: nil))
      return
    }

    guard let activityId = activeActivityIds[orderId] else {
      result(FlutterError(code: "NOT_FOUND", message: "No activity found for orderId", details: nil))
      return
    }

    let status = args["status"] as? String ?? "updated"
    let statusLabel = args["statusLabel"] as? String ?? "Order Updated"
    let progress = args["progress"] as? Double ?? 0.5
    let fulfillment = args["fulfillment"] as? String ?? "Delivery"
    let eta = args["eta"] as? String

    let contentState = OrderLiveActivityAttributes.ContentState(
      status: status,
      statusLabel: statusLabel,
      progress: progress,
      eta: eta,
      fulfillment: fulfillment
    )

    Task {
      // Find the activity by ID
      for activity in Activity<OrderLiveActivityAttributes>.activities {
        if activity.id == activityId {
          await activity.update(
            ActivityContent(state: contentState, staleDate: nil)
          )
          break
        }
      }

      DispatchQueue.main.async {
        result(nil)
      }
    }
  }

  @available(iOS 16.2, *)
  private func handleEndActivity(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let orderId = args["orderId"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing orderId", details: nil))
      return
    }

    endExistingActivity(orderId: orderId)
    result(nil)
  }

  @available(iOS 16.2, *)
  private func endExistingActivity(orderId: String) {
    guard let activityId = activeActivityIds[orderId] else { return }

    Task {
      for activity in Activity<OrderLiveActivityAttributes>.activities {
        if activity.id == activityId {
          await activity.end(nil, dismissalPolicy: .immediate)
          break
        }
      }
    }

    activeActivityIds.removeValue(forKey: orderId)
  }
}

// MARK: - Order Live Activity Attributes
// This struct defines the data model for the Live Activity
// It must match the structure in OrderLiveActivity.swift in the widget extension

@available(iOS 16.1, *)
public struct OrderLiveActivityAttributes: ActivityAttributes {
  // MARK: - Content State (Dynamic data updated via push)
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

  // MARK: - Static Attributes (Set at creation, never change)
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
