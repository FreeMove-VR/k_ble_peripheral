import Flutter
import UIKit

public class KBlePeripheralPlugin: NSObject, FlutterPlugin {

  private let advertisingHandler: AdvertisingHandler
  private let gattHandler: GattHandler

  init(stateChangedHandler: StateChangedHandler) {
    self.stateChangedHandler = stateChangedHandler
    flutterBlePeripheralManager = FlutterBlePeripheralManager(stateChangedHandler: stateChangedHandler)
    super.init()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    AdvertisingHandler.register(registrar)
    GattHandler.register(registrar)
  }
}
