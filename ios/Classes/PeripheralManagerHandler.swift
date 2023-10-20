import CoreBluetooth
import Flutter

class PeripheralManagerHandler: NSObject, FlutterPlugin, CBPeripheralManagerDelegate, FlutterStreamHandler {
    private var peripheralManager: CBPeripheralManager?
    private var eventSink: FlutterEventSink?

    init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = PeripheralManagerHandler()

//         let gattChannel = FlutterMethodChannel(name: "m:kbp/gatt", binaryMessenger: registrar.messenger())
        let advertisingChannel = FlutterMethodChannel(name: "m:kbp/advertising", binaryMessenger: registrar.messenger())

//         registrar.addMethodCallDelegate(instance, channel: gattChannel)
        registrar.addMethodCallDelegate(instance, channel: advertisingChannel)

        let eventChannel = FlutterEventChannel(name: "e:kbp/gatt", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        let requestNumber = CharacteristicDelegate.addRequest(request)

        let readRequestEvent: [String: Any] = [
            "event": "CharacteristicReadRequest",
            "requestId": requestNumber,
            "entityId": CharacteristicDelegate.getEntityId(request.characteristic),
        ]

        eventSink(readRequestEvent)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest])
    {
        for request in requests {
            let requestNumber = CharacteristicDelegate.addRequest(request)

            let readRequestEvent: [String: Any] = [
                "event": "CharacteristicWriteRequest",
                "requestId": requestNumber,
                "entityId": CharacteristicDelegate.getEntityId(request.characteristic),
                "value": request.value
            ]

            eventSink(writeRequestEvent)
        }
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
                let requestId = args["requestId"] as? Int, 
                let value = Data((args["value"] as? [Int]).map { UInt8($0) })
            else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }

            guard var request = CharacteristicDelegate.popRequest(requestId)
            else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "No Request of ID found", details: nil))
                return
            }
            
            request.value(Data(value))

            peripheralManager?.respond(to: request, withResult: .success)
            result(nil)

        case "char/notify":
            guard let args = call.arguments as? [String: Any],
                let characteristic = CharacteristicDelegate.getEntityId(args["charEntityId"]),
                let requestId = args["requestId"] as? Int, 
                let value = Data((args["value"] as? [Int]).map { UInt8($0) })
            else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }

            peripheralManager?.updateValue(value: value, for: CBMutableCharacteristic, onSubscribedCentrals: [CBCentral]?)

            result(nil)
            
        case "service/create":
            guard let args = call.arguments as? [String: Any],
                let entityId = CharacteristicDelegate.getEntityId(args["entityId"]),
                let uuid = args["uuid"] as? String, 
                let type = args["type"] as? Int, 
                let characteristicsData = arguments["characteristics"] as? [[String: Any]] else {
                    result(FlutterError(code: "InvalidArguments", message: "Invalid arguments for service/create", details: nil))
                    return nil
                }

                let characteristics = characteristicsData.map { charDict in
                    if let charUuid = charDict["uuid"] as? String,
                    let charProperties = charDict["properties"] as? Int,
                    let charPermissions = charDict["permissions"] as? Int,
                    let charEntityId = charDict["entityId"] as? String {
                        
                        return CharacteristicDelegate.createCharacteristic(charUuid, charProperties, charPermissions, charEntityId)
                    } else {
                        // Handle invalid characteristics data

                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                        return nil
                    }
                }

                GattServiceDelegate.createKService(entityId, uuid, type, characteristics)
//                GattServiceDelegate.createKService(call.arguments as Map<String, Any>)
                result.success(null)

        case "service/activate":
            guard let entityId = call.arguments as? String else {
                    result(FlutterError(code: "InvalidArguments", message: "Invalid arguments for service/create", details: nil))
                    return nil
                }

            activateService(entityId)

            result(nil)
            
        case "service/inactivate":
            guard let entityId = call.arguments as? String else {
                    result(FlutterError(code: "InvalidArguments", message: "Invalid arguments for service/create", details: nil))
                    return nil
                }

            inactivateService(entityId)
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

    private func setServiceState(entityId: String, state: Bool) {

    }

    private func activateService(entityId: String) {
        guard let kService = services[entityId] else {
            fatalError("Not Found Gatt Service, may be the entityId is wrong.")
        }
        peripheralManager.add(kService.service)
        GattServiceDelegate.setServiceState(entityId, true)
    }

    private func inactivateService(entityId: String) {
        guard let kService = services[entityId] else {
            fatalError("Not Found Gatt Service, may be the entityId is wrong.")
        }
        peripheralManager.remove(kService.service)
        GattServiceDelegate.setServiceState(entityId, false)
    }
}