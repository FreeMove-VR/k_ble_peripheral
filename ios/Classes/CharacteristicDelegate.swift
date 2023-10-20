import CoreBluetooth

class CharacteristicDelegate {
    // Store all created characteristics, using entityId as the key for retrieval
    private var characteristics: [String: KGattCharacteristic] = [:]
    private var requests: [Int: CBATTRequest] = [:]
    private var requestCounter: Int = 0

    func addRequest(request: CBATTRequest) -> Int {
        let requestNumber = requestCounter
        requestCounter = requestCounter + 1

        if(requestCounter == Int.max)
        {
            requestCounter = 0
        }

        requests[requestNumber] = request
        return requestNumber
    }

    func popRequest(requestNumber: Int) -> request?
    {
        guard let request = requests.removeValue(forKey: requestNumber) else {
            return nil
        }
        return request
    }

    func getEntityId(c: CBMutableCharacteristic) -> String? {
        for (key, value) in characteristics {
            if value.characteristic == c {
                return key
            }
        }
        return nil
    }

    func getKChar(entityId: String) -> KGattCharacteristic {
        guard 
            let kChar = characteristics[entityId] 
        else {
            fatalError("Not Found Gatt Characteristic, may be the entityId is wrong.")
        }
        return kChar
    }

    func createCharacteristic(uuid: String, properties: CBCharacteristicProperties, permissions: CBAttributePermissions, entityId: String) -> KGattCharacteristic {
        let characteristic = CBMutableCharacteristic(
            type: CBUUID(string: uuid),
            properties: properties,
            value: nil,
            permissions: permissions
        )

        let kChar = KGattCharacteristic(entityId: entityId, characteristic: characteristic)
        characteristics[entityId] = kChar
        return kChar
    }
}

extension CBMutableCharacteristic {
    func toMap() -> [String: Any?] {
        return [
            "uuid": uuid.uuidString,
            "properties": properties.rawValue,
            "permissions": permissions.rawValue
        ]
    }
}
