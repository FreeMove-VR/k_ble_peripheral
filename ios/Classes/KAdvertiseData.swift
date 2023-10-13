import CoreBluetooth

class KAdvertiseData {
    private var serviceData: [CBUUID] = []

    init(settingMap: [String: Any]) {
        setByMap(settingMap: settingMap)
    }

    func toAdvertiseData() -> [String: Any] {
        var advertiseData: [String: Any] = [:]

        for (uuid, _data) in serviceData {
            advertiseData[CBAdvertisementDataServiceUUIDsKey] = [uuid]
        }

        return advertiseData
    }

    func setByMap(settingMap: [String: Any]) {
        if let serviceData = settingMap["serviceData"] as? [String: Any] {
            for (key, value) in serviceData {
                if let uuid = CBUUID(string: key) {
                    serviceData.append(uuid)
                }
            }
        }
    }
}
