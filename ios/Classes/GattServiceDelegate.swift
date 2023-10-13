import CoreBluetooth

class GattServiceDelegate {
    // Store all created services, using entityId as the key for retrieval
    private var services: [String: KGattService] = [:]
    private var gattServer: CBPeripheralManager!

    /**
     * Activate Service
     */
    func activate(entityId: String) {
        guard let kService = services[entityId] else {
            fatalError("Not Found Gatt Service, may be the entityId is wrong.")
        }
        gattServer.add(kService.service)
        kService.activated = true
    }

    /**
     * Deactivate Service
     */
    func inactivate(entityId: String) {
        guard let kService = services[entityId] else {
            fatalError("Not Found Gatt Service, may be the entityId is wrong.")
        }
        gattServer.remove(kService.service)
        kService.activated = false
    }

    func createKService(entityId: String, uuid: String, type: CBServiceType, characteristics: [KGattCharacteristic]) -> KGattService {
        let service = CBMutableService(type: CBUUID(string: uuid), primary: type == .primary)
        characteristics.forEach {
            service.characteristics?.append($0.characteristic)
        }
        let kService = KGattService(entityId: entityId, service: service, activated: false)
        services[entityId] = kService
        return kService
    }
}
