import Flutter
import UIKit

public class JwplayerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "org.kqed.jwplayer", binaryMessenger: registrar.messenger())
    let instance = JwplayerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "init":
      result("iOS " + UIDevice.current.systemVersion)
    case "play":
      result("iOS " + UIDevice.current.systemVersion)
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
