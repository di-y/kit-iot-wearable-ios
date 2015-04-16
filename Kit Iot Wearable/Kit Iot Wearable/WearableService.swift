//
//  WearableService.swift
//  kit-iot-wearable
//
//  Created by Vitor Leal on 4/1/15.
//  Copyright (c) 2015 Telefonica VIVO. All rights reserved.
//
import Foundation
import CoreBluetooth


let ServiceUUID = CBUUID(string: "FFE0")
let CharacteristicUIID = CBUUID(string: "FFE1")
let WearableServiceChangedStatusNotification = "WearableServiceChangedStatusNotification"
let WearableCharacteristicNewValue = "WearableCharacteristicNewValue"


class WearableService: NSObject, CBPeripheralDelegate {
    var peripheral: CBPeripheral?
    var peripheralCharacteristic: CBCharacteristic?
    
    init(initWithPeripheral peripheral: CBPeripheral) {
        super.init()

        self.peripheral = peripheral
        self.peripheral?.delegate = self
    }
    
    deinit {
        self.reset()
    }
    
    // Start discovering services
    func startDiscoveringServices() {
        self.peripheral?.discoverServices([ServiceUUID])
    }
    
    // Reset
    func reset() {
        if peripheral != nil {
            peripheral = nil
        }
        self.sendWearableServiceNotificationWithIsBluetoothConnected(false)
    }
    
    // Look for bluetooth with the service FFEO
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        let uuidsForBTService: [CBUUID] = [CharacteristicUIID]
        
        if (peripheral != self.peripheral || error != nil) {
            return
        }
        
        if ((peripheral.services == nil) || (peripheral.services.count == 0)) {
            return
        }
        
        // Find characteristics
        for service in peripheral.services {
            if service.UUID == ServiceUUID {
                peripheral.discoverCharacteristics(uuidsForBTService, forService: service as! CBService)
            }
        }
    }
    
    // Look for the bluetooth characteristics
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if (peripheral != self.peripheral || error != nil) {
            return
        }
        
        for characteristic in service.characteristics {
            if characteristic.UUID == CharacteristicUIID {
                self.peripheralCharacteristic = (characteristic as! CBCharacteristic)
                peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
                
                self.sendWearableServiceNotificationWithIsBluetoothConnected(true)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError!) {
        
        if ((error) != nil) {
            println("Error changing notification state: %@", error.description)
        }
    
        if (!characteristic.UUID.isEqual(peripheralCharacteristic?.UUID)) {
            return
        }
    
        if (characteristic.isNotifying) {
            println("Notification began on %@", characteristic)
            //[peripheral readValueForCharacteristic:characteristic];
            
        } else {
            println("Notification stopped on %@.  Disconnecting", characteristic)
            //[self.manager cancelPeripheralConnection:self.peripheral];
        }
    }
    
    // MARK:
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if ((error) != nil) {
            println("Error changing notification state: %@", error.description)
        }
        
        if (!characteristic.UUID.isEqual(peripheralCharacteristic?.UUID)) {
            return
        }
        
        var value = NSString(bytes: characteristic.value.bytes, length: characteristic.value.length, encoding: NSUTF8StringEncoding)
        value = value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if let stringVal = value {
            self.sendWearableCharacteristicNewValue(value!)
        }
    }
    
    // Send command
    func sendCommand(command: NSString) {
        let str = NSString(string: command)
        let data = NSData(bytes: str.UTF8String, length: str.length)
        
        self.peripheral?.writeValue(data, forCharacteristic: self.peripheralCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
    }
    
    // Send wearable connected notification
    func sendWearableServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: Bool) {
        let connectionDetails = ["isConnected": isBluetoothConnected]

        NSNotificationCenter.defaultCenter().postNotificationName(WearableServiceChangedStatusNotification, object: self, userInfo: connectionDetails)
    }
    
    // Send characteristic value
    func sendWearableCharacteristicNewValue(value: NSString) {
        let stringVal = [NSString(): value]
        
        NSNotificationCenter.defaultCenter().postNotificationName(WearableCharacteristicNewValue, object: self, userInfo: stringVal)
    }
}
