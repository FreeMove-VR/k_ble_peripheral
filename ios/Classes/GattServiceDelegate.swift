import CoreBluetooth

class GattServiceDelegate {
    // Store all created services, using entityId as the key for retrieval
    private var services: [String: KGattService] = [:]
    private var gattServer: CBPeripheralManager!

    private let SERVICE_TYPE_PRIMARY = 0

    func getService(entityId: String) -> KGattService {
        guard let kService = services[entityId] else {
            fatalError("Not Found Gatt Service, may be the entityId is wrong.")
        }
        return kService
    }

    func setServiceState(entityId: String, state: Bool) {
        guard let kService = services[entityId] else {
            fatalError("Not Found Gatt Service, may be the entityId is wrong.")
        }
        kService.activated = state
    }

    func createKService(entityId: String, uuid: String, type: CBServiceType, characteristics: [KGattCharacteristic]) -> KGattService {
        let service = CBMutableService(type: CBUUID(string: uuid), primary: type == SERVICE_TYPE_PRIMARY)
        characteristics.forEach {
            service.characteristics?.append($0.characteristic)
        }
        let kService = KGattService(entityId: entityId, service: service, activated: false)
        services[entityId] = kService
        return kService
    }
}
