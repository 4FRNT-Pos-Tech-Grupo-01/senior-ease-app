import Flutter
import UIKit

/// Ciclo de vida UIScene: ver `UIApplicationSceneManifest` em `Info.plist`
/// (`FlutterSceneDelegate` + storyboard `Main`).
///
/// Com Flutter **3.41+**, a documentação recomenda migrar o registo de plugins
/// para `FlutterImplicitEngineDelegate.didInitializeImplicitFlutterEngine`;
/// em **3.35** mantém-se aqui (compatível com UIScene).
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
