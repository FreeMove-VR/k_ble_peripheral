import Flutter
import UIKit

public class KBlePeripheralPlugin: NSObject, FlutterPlugin {

  init(stateChangedHandler: StateChangedHandler) {
    self.stateChangedHandler = stateChangedHandler
    flutterBlePeripheralManager = FlutterBlePeripheralManager(stateChangedHandler: stateChangedHandler)
    super.init()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    PeripheralManagerHandler.register(registrar)
  }
}
