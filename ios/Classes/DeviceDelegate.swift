import CoreBluetooth

class DeviceDelegate {
    // Store all connected devices, using address as the key
    private var devices: [String: CBPeripheral] = [:]

    func newDevice(device: CBPeripheral) {
        devices[device.identifier.uuidString] = device
    }
    
    func getDevice(address: String) -> CBPeripheral? {
        return devices[address]
    }
}

extension CBPeripheral {
    func toMap() -> [String: Any?] {
        let mAlias: String? = {
            if #available(iOS 14.0, *) {
                return self.name
            } else {
                return nil
            }
        }()
        
        return [
            "address": identifier.uuidString,
            "name": name,
            "bondState": CBPeripheralBondState(rawValue: state.rawValue),
            "alias": mAlias,
            "type": CBPeripheralType(rawValue: type.rawValue)
        ]
    }
}
