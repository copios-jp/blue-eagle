//
//  BluetoothService.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/21.
//
import CoreBluetooth
import Foundation

// MARK: - Bluetooth Service
/*
 
 I need to know
 
 State of central manager
 
 State of peripheral (connected/not found)
 
 Heart Rate
 
 
 */
let MAX_IDENTICAL_READING_COUNT = 10

extension NSNotification.Name {
    static let HeartRate = NSNotification.Name(rawValue: "heart_rate")
}

class BluetoothService: NSObject, ObservableObject {
    var centralManager: CBCentralManager? = nil
    @Published var peripheral: CBPeripheral!
    @Published var state: CBManagerState = CBManagerState.unknown
    @Published var devices = Set<CBPeripheral>()
    
    @Published var receiving: Bool = false
    @Published var pulse: Bool = false
    
    private var identicalReadingCount: Int = 0
    private var lastHeartRate: Int = 0
    
    func connect(_ peripheral: CBPeripheral) {
        guard let manager = centralManager else {
            return
        }
        
        if(peripheral == self.peripheral) {
            return
        }
        
        if(self.peripheral !== nil) {
            disconnect(self.peripheral)
        }
        
        self.peripheral = peripheral
        peripheral.delegate = self
        manager.connect(peripheral)
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
             DispatchQueue.main.async {
                 
            if(peripheral.state != CBPeripheralState.connected) {
                self.disconnect(peripheral)
                self.devices.remove(peripheral)
            }
             }
         }

    }
   
    func disconnect(_ peripheral: CBPeripheral) {
         guard let manager = centralManager else {
            return
        }
        
          manager.cancelPeripheralConnection(peripheral)
               
    }
    func scan(_ timeout: Bool = true) {
        stopScan()
        guard let manager = centralManager else {
            return
        }
        
        if(manager.state == CBManagerState.poweredOn) {
            manager.scanForPeripherals(withServices: [GATT.heartRate] , options: nil)
        }
        if(timeout) {
         Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { timer in
             DispatchQueue.main.async {
                 self.stopScan()
             }
         }
        }
    }
    
    func stopScan() {
        guard let manager = centralManager else {
            return
        }
        
        if(manager.isScanning) {
            manager.stopScan()
        }
    }
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        print("Bluetooth Service init")
        scan()
    }
    
    
    func onHeartRateReceived(_ inHeartRate: Int) {
        
        self.identicalReadingCount = inHeartRate != lastHeartRate ? 0 : identicalReadingCount + 1
        
        self.receiving = identicalReadingCount < MAX_IDENTICAL_READING_COUNT
        
        NotificationCenter.default.post(name: NSNotification.Name.HeartRate, object:self, userInfo: ["heart_rate" : inHeartRate])
        
        self.pulse.toggle()
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
            DispatchQueue.main.async {
                self.pulse.toggle()
            }
        }
    }
}

// MARK: CBCentralManagerDelegate

extension BluetoothService: CBCentralManagerDelegate {
    
    /// Bluetoothのステータスを取得する(CBCentralManagerの状態が変わる度に呼び出される)
    ///
    /// - Parameter central: CBCentralManager
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if(central.state == CBManagerState.poweredOn) {
            scan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover foundPeripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        devices.insert(foundPeripheral)
        if(peripheral == nil) {
            connect(foundPeripheral)
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        peripheral.discoverServices([GATT.heartRate])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
        if(peripheral == self.peripheral) {
            self.peripheral = nil
        }
        self.receiving = false
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("connection failed")
    }
    
}

// MARK: CBPeripheralDelegate

extension BluetoothService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        switch characteristic.uuid {
            
        case GATT.bodySensorLocation:
            let bodySensorLocation = bodyLocation(from: characteristic)
            print("ERM..... \(bodySensorLocation)")
        case GATT.heartRateMeasurement:
            let bpm = heartRate(from: characteristic)
            onHeartRateReceived(bpm)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    private func bodyLocation(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value,
              let byte = characteristicData.first else { return "Error" }
        
        switch byte {
        case 0: return "Other"
        case 1: return "Chest"
        case 2: return "Wrist"
        case 3: return "Finger"
        case 4: return "Hand"
        case 5: return "Ear Lobe"
        case 6: return "Foot"
        default:
            return "Reserved for future use"
        }
    }
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        // See: https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_measurement.xml
        // The heart rate mesurement is in the 2nd, or in the 2nd and 3rd bytes, i.e. one one or in two bytes
        // The first byte of the first bit specifies the length of the heart rate data, 0 == 1 byte, 1 == 2 bytes
        let firstBitValue = byteArray[0] & 0x01
        
        if firstBitValue == 0 {
            // Heart Rate Value Format is in the 2nd byte
            return Int(byteArray[1])
        } else {
            // Heart Rate Value Format is in the 2nd and 3rd bytes
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
        
    }
}
