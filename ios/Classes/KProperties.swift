import CoreBluetooth

class KProperties {

  static let PROPERTY_BROADCAST = 0x01;
  static let PROPERTY_READ = 0x02;
  static let PROPERTY_WRITE_NO_RESPONSE = 0x04;
  static let PROPERTY_WRITE = 0x08;
  static let PROPERTY_NOTIFY = 0x10;
  static let PROPERTY_INDICATE = 0x20;
  static let PROPERTY_SIGNED_WRITE = 0x40;
  static let PROPERTY_EXTENDED_PROPS = 0x80;

    private let characteristicProperties: CBCharacteristicProperties = []   

    init(properties: Int) {
        setByMap(properties: properties)
    }

    func getProperties() -> [String: Any] {
        return characteristicProperties
    }

    func setByMap(properties: Int) {
        if (properties & PROPERTY_BROADCAST) != 0 {
            characteristicProperties.insert(.broadcast)
        }
        if (properties & PROPERTY_READ) != 0 {
            characteristicProperties.insert(.read)
        }
        if (properties & PROPERTY_WRITE_NO_RESPONSE) != 0 {
            characteristicProperties.insert(.writeWithoutResponse)
        }
        if (properties & PROPERTY_WRITE) != 0 {
            characteristicProperties.insert(.write)
        }
        if (properties & PROPERTY_NOTIFY) != 0 {
            characteristicProperties.insert(.notify)
        }
        if (properties & PROPERTY_INDICATE) != 0 {
            characteristicProperties.insert(.indicate)
        }
        if (properties & PROPERTY_SIGNED_WRITE) != 0 {
            characteristicProperties.insert(.authenticatedSignedWrites)
        }
        if (properties & PROPERTY_EXTENDED_PROPS) != 0 {
            characteristicProperties.insert(.extendedProperties)
        }
    }
}
