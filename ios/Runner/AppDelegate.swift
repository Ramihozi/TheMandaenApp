import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private let versionChannel = "com.example.app/version" // Channel name

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Setup method channel
    let controller = window?.rootViewController as! FlutterViewController
    let methodChannel = FlutterMethodChannel(name: versionChannel,
                                              binaryMessenger: controller.binaryMessenger)
    methodChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "getVersion" {
        self?.handleGetVersion(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handleGetVersion(result: @escaping FlutterResult) {
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      result(version)
    } else {
      result(FlutterError(code: "UNAVAILABLE",
                          message: "Version information unavailable",
                          details: nil))
    }
  }
}
