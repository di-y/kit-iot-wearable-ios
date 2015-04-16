//
//  Wearable.swift
//  kit-iot-wearable
//
//  Created by Vitor Leal on 4/1/15.
//  Copyright (c) 2015 Telefonica VIVO. All rights reserved.
//
import Foundation
import CoreBluetooth


let wearable = Wearable()

class Wearable: NSObject, CBCentralManagerDelegate {
    
    private var centralManager: CBCentralManager?
    private var peripheralBLE: CBPeripheral?
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    override init() {
        super.init()
        let centralQueue = dispatch_queue_create("com.wearable", DISPATCH_QUEUE_SERIAL)
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    func startScanning() {
        if let central = centralManager {
            central.scanForPeripheralsWithServices([ServiceUUID], options: nil)
        }
    }
    
    var wearableService: WearableService? {
        didSet {
            if let service = self.wearableService {
                service.startDiscoveringServices()
            }
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        if ((peripheral == nil) || (peripheral.name == nil) || (peripheral.name == "")) {
            return
        }
        
        if ((self.peripheralBLE == nil) || (self.peripheralBLE?.state == CBPeripheralState.Disconnected)) {
            var wearableName = defaults.stringForKey("wearableName")
            
            if (peripheral.name == wearableName) {
                self.peripheralBLE = peripheral
                self.wearableService = nil
                
                central.connectPeripheral(peripheral, options: nil)
            }
        }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        if (peripheral == nil) {
            return;
        }
        
        // Create new service class
        if (peripheral == self.peripheralBLE) {
            self.wearableService = WearableService(initWithPeripheral: peripheral)
        }
        
        central.stopScan()
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        
        if (peripheral == nil) {
            return;
        }
        
        if (peripheral == self.peripheralBLE) {
            self.wearableService = nil;
            self.peripheralBLE = nil;
        }
        
        self.startScanning()
    }
    
    // MARK: - Private
    func clearDevices() {
        self.wearableService = nil
        self.peripheralBLE = nil
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch (central.state) {
            case CBCentralManagerState.PoweredOff:
                self.clearDevices()
            
            case CBCentralManagerState.Unauthorized:
                break
            
            case CBCentralManagerState.Unknown:
                break
            
            case CBCentralManagerState.PoweredOn:
                self.startScanning()
            
            case CBCentralManagerState.Resetting:
                self.clearDevices()
            
            case CBCentralManagerState.Unsupported:
                break
            
            default:
                break
        }
    }
}