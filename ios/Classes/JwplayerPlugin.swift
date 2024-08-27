import Flutter
import UIKit
import JWPlayerKit

enum Method: String, CaseIterable {
    case initializeJwPlayer
    case play
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

// If we plan to make this a public package, we will need to change
// the channelName to something generic
private var channelName: String = "org.kqed.jwplayer"

public class JwplayerPlugin: NSObject, FlutterPlugin {
    private var callbackChannel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = JwplayerPlugin()
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.callbackChannel = channel
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
        case .play:
            let url = args["url"] as? String
            let videoTitle = args["videoTitle"] as? String
            let videoDescription = args["videoDescription"] as? String
            launchVerticalPlayer(url, videoTitle, videoDescription)
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
    
     private func launchVerticalPlayer(_ url: String?, _ videoTitle: String?, _ videoDescription: String?) {
        if (url == nil) {
            self.callbackToFlutter(CallbackMethod.sdkUrlIsNull)
            return
        }
        
        if let topController = topViewController() {
            let vc = VerticalPlayerViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.url = url
            vc.videoTitle = videoTitle
            vc.videoDescription = videoDescription
            topController.present(vc, animated: true, completion: nil)
            callbackToFlutter(CallbackMethod.sdkPlayMethodCalled, [Arguments.videoUrl.rawValue: url])
        } else {
            callbackToFlutter(CallbackMethod.sdkUnableToFindVC)
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
