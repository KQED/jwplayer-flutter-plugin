import Flutter
import UIKit
import JWPlayerKit

enum Method: String, CaseIterable {
    case initializeJwPlayer
    case play
    case setMuted
    case getPosition
    case seekTo
    case resume
    case unknown
}

enum Arguments: String, CaseIterable {
    case licenseKey = "licenseKey"
    case videoUrl = "url"
}

enum CallbackMethod: String, CaseIterable {
    case sdkLicenseKeySetSuccess = "org.kqed.plugin.jwplayer_license_key_set_success"
    case sdkLicenseKeyNull = "org.kqed.plugin.jwplayer_license_key_is_null"
    case sdkInitializeError = "org.kqed.plugin.sdk_initialize_error"
    case sdkPlayMethodCalled = "org.kqed.plugin.play_method_called"
    case sdkUnknownMethodError = "org.kqed.plugin.unknown_method_error"
    case sdkUrlIsNull = "org.kqed.plugin.video_url_is_null"
    case sdkArgumentsMapError = "org.kqed.plugin.error_accessing_arguments_map"
    case sdkUnableToFindVC = "org.kqed.plugin.unable_to_find_viewcontroller"
}

private var channelName: String = "org.kqed.jwplayer"

public class JwplayerPlugin: NSObject, FlutterPlugin {
    private var callbackChannel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = JwplayerPlugin()
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.callbackChannel = channel

        let viewFactory = JwplayerViewFactory(messenger: registrar.messenger())
        registrar.register(viewFactory, withId: "org.kqed.jwplayer/jwplayer_view")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        guard let args = call.arguments as? [String: Any] else {
            callbackToFlutter(CallbackMethod.sdkArgumentsMapError)
            return
        }
        
        let method = Method(rawValue: call.method) ?? .unknown
        switch method {
        case .initializeJwPlayer:
            let licenseKey = args["licenseKey"] as? String
            setLicenseKey(licenseKey)
        case .setMuted:
            if let viewIdNum = args["viewId"] as? NSNumber,
               let muted = args["muted"] as? Bool {
                let viewId = viewIdNum.int64Value
                JwplayerViewRegistry.setMuted(viewId: viewId, muted: muted)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "viewId and muted required", details: nil))
            }
        case .play:
            let url = args["url"] as? String
            let videoTitle = args["videoTitle"] as? String
            let videoDescription = args["videoDescription"] as? String
            let startPosition = args["startPosition"] as? NSNumber
            let loop = (args["loop"] as? NSNumber)?.boolValue ?? false
            let allowsPictureInPicture = (args["allowsPictureInPicture"] as? NSNumber)?.boolValue ?? false
            guard let args = call.arguments as? [String: Any],
              let captionsArray = args["captions"] as? [[String: Any]] else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments passed", details: nil))
                return
            }

            let captions = captionsArray.compactMap { Caption(from: $0) }

            launchVerticalPlayer(
                url,
                videoTitle,
                videoDescription,
                captions,
                startPosition: startPosition?.doubleValue,
                loop: loop,
                allowsPictureInPicture: allowsPictureInPicture,
                onDismiss: { position in
                    result(position)
                }
            )
        case .getPosition:
            if let viewIdNum = args["viewId"] as? NSNumber {
                let position = JwplayerViewRegistry.getPosition(viewId: viewIdNum.int64Value)
                result(position)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "viewId required", details: nil))
            }
        case .seekTo:
            if let viewIdNum = args["viewId"] as? NSNumber,
               let position = args["position"] as? NSNumber {
                JwplayerViewRegistry.seekTo(viewId: viewIdNum.int64Value, position: position.doubleValue)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "viewId and position required", details: nil))
            }
        case .resume:
            if let viewIdNum = args["viewId"] as? NSNumber {
                JwplayerViewRegistry.resume(viewId: viewIdNum.int64Value)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "viewId required", details: nil))
            }
        default:
            callbackToFlutter(CallbackMethod.sdkUnknownMethodError)
        }
    }
    
    private func setLicenseKey(_ licenseKey: String?) {
        if (licenseKey == nil) {
            self.callbackToFlutter(CallbackMethod.sdkLicenseKeyNull)
        }
        
        JWPlayerKitLicense.setLicenseKey(licenseKey!)
        self.callbackToFlutter(CallbackMethod.sdkLicenseKeySetSuccess)
    }
    
    private func launchVerticalPlayer(
        _ url: String?,
        _ videoTitle: String?,
        _ videoDescription: String?,
        _ captions: [Caption]?,
        startPosition: Double? = nil,
        loop: Bool = false,
        allowsPictureInPicture: Bool = false,
        onDismiss: @escaping (Double) -> Void
    ) {
        if (url == nil) {
            self.callbackToFlutter(CallbackMethod.sdkUrlIsNull)
            onDismiss(-1)
            return
        }
        
        if let topController = topViewController() {
            let vc = VerticalPlayerViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.url = url
            vc.videoTitle = videoTitle
            vc.videoDescription = videoDescription
            vc.captions = captions
            vc.startPosition = startPosition
            vc.loop = loop
            vc.allowsPictureInPicture = allowsPictureInPicture
            vc.onDismiss = onDismiss
            topController.present(vc, animated: true, completion: nil)
            callbackToFlutter(CallbackMethod.sdkPlayMethodCalled, [Arguments.videoUrl.rawValue: url])
        } else {
            callbackToFlutter(CallbackMethod.sdkUnableToFindVC)
            onDismiss(-1)
        }
    }
    
    private func topViewController() -> UIViewController? {
        if let rootViewController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController {
            return getTopViewController(from: rootViewController)
        }
        callbackToFlutter(CallbackMethod.sdkUnableToFindVC)
        return nil
    }
    
    private func getTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return getTopViewController(from: presentedViewController)
        }
        if let navigationController = viewController as? UINavigationController, let visibleViewController = navigationController.visibleViewController {
            return getTopViewController(from: visibleViewController)
        }
        if let tabBarController = viewController as? UITabBarController, let selectedViewController = tabBarController.selectedViewController {
            return getTopViewController(from: selectedViewController)
        }
        return viewController
    }
    
    private func callbackToFlutter(_ callbackMethod: CallbackMethod, _ arguments: Any? = nil) {
        self.callbackChannel?.invokeMethod(callbackMethod.rawValue, arguments: arguments)
    }
}

// Inlined from JwplayerViewRegistry.swift so it compiles with the existing Pods project.
class JwplayerViewRegistry {
    private static var views: [Int64: WeakRef<JwplayerPlatformView>] = [:]
    private static let lock = NSLock()

    static func register(viewId: Int64, view: JwplayerPlatformView) {
        lock.lock()
        defer { lock.unlock() }
        views[viewId] = WeakRef(view)
    }

    static func unregister(viewId: Int64) {
        lock.lock()
        defer { lock.unlock() }
        views.removeValue(forKey: viewId)
    }

    static func setMuted(viewId: Int64, muted: Bool) {
        lock.lock()
        defer { lock.unlock() }
        if let ref = views[viewId], let view = ref.value {
            view.setMuted(muted)
        }
    }

    static func getPosition(viewId: Int64) -> Double {
        lock.lock()
        defer { lock.unlock() }
        if let ref = views[viewId], let view = ref.value {
            return view.getPosition()
        }
        return -1
    }

    static func seekTo(viewId: Int64, position: Double) {
        lock.lock()
        defer { lock.unlock() }
        if let ref = views[viewId], let view = ref.value {
            view.seekTo(position)
        }
    }

    static func resume(viewId: Int64) {
        lock.lock()
        defer { lock.unlock() }
        if let ref = views[viewId], let view = ref.value {
            view.resume()
        }
    }
}

private class WeakRef<T: AnyObject> {
    weak var value: T?
    init(_ value: T) {
        self.value = value
    }
}
