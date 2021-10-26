import Flutter
import UIKit

public class SwiftFlutterTencentVapPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let factory = TencentVapViewFactory(registrar: registrar)
    registrar.register(factory, withId: "flutter_tencent_vap")
  }
}
