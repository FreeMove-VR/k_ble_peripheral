import CoreBluetooth
import Flutter

class AdvertisingHandler: NSObject, FlutterPlugin {
    private var peripheralManager: CBPeripheralManager?

    init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "m:kbp/advertising", binaryMessenger: registrar.messenger())
        let instance = AdvertisingHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startAdvertising":
            guard let args = call.arguments as? [String: Any],
                let id = args["Id"] as? String,
                let kAdvertiseSetting = KAdvertiseSetting(args["AdvertiseSetting"] as? [String: Any]),
                let kAdvertiseData = KAdvertiseData(args["AdvertiseData"] as? [String: Any])
                  
            else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }
            
            startAdvertising(id, kAdvertiseSetting, kAdvertiseData, scanResponseData, result: result)
            result(nil)
            
        case "stopAdvertising":
            guard let id = call.arguments as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }
            
            stopAdvertising(id, result: result)
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startAdvertising(id: String, advertiseSetting: KAdvertiseSetting, advertiseData: KAdvertiseData, result: @escaping FlutterResult) {

        let services: [String] = advertiseData.serviceData
        
        let advertisement: [String : Any] = [CBAdvertisementDataServiceUUIDsKey: services]

        if let name: String = advertiseSetting.name {
            advertisement.append([CBAdvertisementDataLocalNameKey: name])
        }

        peripheralManager.startAdvertising(advertisement)

    }

    private func stopAdvertising(_ id: String, result: @escaping FlutterResult) {
        // Stop advertising for the given ID
        
        // Example: Stop advertising
        peripheralManager?.stopAdvertising()
    }
}
