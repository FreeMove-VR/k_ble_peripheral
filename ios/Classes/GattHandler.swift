import CoreBluetooth
import Flutter

class GattHandler: NSObject, FlutterPlugin {

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "m:kbp/gatt", binaryMessenger: registrar.messenger())
        let instance = GattHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "char/create":
            
            guard let args = call.arguments as? [String: Any],
                let uuid = args["uuid"] as? String,
                let properties = KProperties(args["properties"] as? Int).getProperties(),
                let permissions = KPermissions(args["permissions"] as? Int).getPermissions(),
                let entityId = args["entityId"] as? String 
            else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }

            CharacteristicDelegate.createCharacteristic(uuid, properties, permissions, entityId)
            result(nil)
            
        case "char/sendResponse":
            guard let args = call.arguments as? [String: Any],
                let address = args["deviceAddress"] as? String, 
                let requestId = args["requestId"] as? Int, 
                let offset = args["offset"] as? Int, 
                let value = Data((args["value"] as? [Int]).map { UInt8($0) })
            else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }

            

            result(nil)

        case "char/notify":
            result(nil)
            
        case "service/create":
            result(nil)

        case "service/activate":
            result(nil)
            
        case "service/inactivate":
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}