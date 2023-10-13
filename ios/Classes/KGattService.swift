import CoreBluetooth

struct KGattService {
    let entityId: String
    let service: CBService
    var activated: Bool = false
}