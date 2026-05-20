import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Clé Google Maps (via bridging header — pas d'import Swift du module GoogleMaps).
    GMSServices.provideAPIKey("AIzaSyCN1MyOGuAiD1EE7WSp74lSMHX2scGHn-A")
    // Firebase : initialisé par le plugin firebase_core (Dart), pas ici.
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
