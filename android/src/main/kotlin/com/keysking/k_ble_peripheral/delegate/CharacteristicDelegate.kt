package com.keysking.k_ble_peripheral.delegate

import android.bluetooth.BluetoothGattCharacteristic
import java.util.*

object CharacteristicDelegate {
    // 保存所有创建的characteristic,key值是entityId,用于检索
    private val characteristics = mutableMapOf<String, BluetoothGattCharacteristic>()

    fun getEntityId(c: BluetoothGattCharacteristic): String? {
        characteristics.forEach {
            if (it.value == c) {
                return it.key
            }
        }
        return null
    }

    fun createCharacteristic(map: Map<String, Any>): BluetoothGattCharacteristic {
        val uuid = map["uuid"] as String
        val properties = map["properties"] as Int
        val permissions = map["permissions"] as Int
        val entityId = map["entityId"] as String
        val characteristic =
            BluetoothGattCharacteristic(UUID.fromString(uuid), properties, permissions)
        characteristics[entityId] = characteristic
        return characteristic
    }
}

fun BluetoothGattCharacteristic.toMap(): MutableMap<String, Any?> {
    return mutableMapOf(
        Pair("uuid", uuid.toString()),
        Pair("properties", properties),
        Pair("permissions", permissions),
    )
}

