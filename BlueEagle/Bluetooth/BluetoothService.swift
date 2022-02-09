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
    
    @Published var state: CBManagerState = CBManagerState.unknown
    @Published var peripherals = Set<CBPeripheral>()
    @Published var peripheral: CBPeripheral?
    
    @Published var receiving: Bool = false
    @Published var isScanning: Bool = false
    @Published var pulse: Bool = false
   
    private var identicalReadingCount: Int = 0
    private var lastHeartRate: Int = 0
     
    func scan(_ timeout: Double = 5.0) {
        guard let manager = centralManager else {
            return
        }
        stopScan()
        if(manager.state == CBManagerState.poweredOn) {
            manager.scanForPeripherals(withServices: [GATT.heartRate] , options: nil)
        }
            Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { timer in
                DispatchQueue.main.async {
                    self.stopScan()
                }
            }
        
        isScanning = true
    }
    
    func stopScan() {
        guard let manager = centralManager else {
            return
        }
        
        isScanning = false
        if(manager.isScanning) {
            manager.stopScan()
        }
    }
      
   
    func connect(_ peripheral: CBPeripheral) {
        guard let manager = centralManager else {
            return
        }

       peripherals.forEach { knownPeripheral in 
            if(knownPeripheral.state == CBPeripheralState.connected) {
                disconnect(knownPeripheral)
            }
        }
         
        self.peripheral = peripheral
        peripheral.delegate = self
        manager.connect(peripheral)
    }
   
    func disconnectAll() {
         guard let manager = centralManager else {
            return
        }

        let peripherals = manager.retrieveConnectedPeripherals(withServices: [GATT.heartRate])
        peripherals.forEach { connected in
          disconnect(connected)
        }
    }
    
    func disconnect(_ peripheral: CBPeripheral) {
        guard let manager = centralManager else {
            return
        }

       peripheral.delegate = nil 
       manager.cancelPeripheralConnection(peripheral)
    }
   
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
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

        lastHeartRate = inHeartRate
    }
}

// MARK: CBCentralManagerDelegate

extension BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if(central.state == CBManagerState.poweredOn) {
            scan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        peripherals.insert(peripheral)
        // print("found peripheral", peripheral.name ?? "unknown monitor")
        guard let preferred = Preferences.standard.heartRateMonitor else {
            connect(peripheral)
            return
        }
        
        if(peripheral.identifier.uuidString == preferred) {
            connect(peripheral)
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Preferences.standard.heartRateMonitor = peripheral.identifier.uuidString

        peripheral.discoverServices([GATT.heartRate])
        self.peripheral = peripheral
        print("connected", peripheral.name ?? "unknown")
            peripherals.forEach { knownPeripheral in 
                if(self.peripheral != knownPeripheral && knownPeripheral.state == CBPeripheralState.connected) {
                    disconnect(knownPeripheral)
                }
            }

    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        peripheral.delegate = nil
        print("disconnected", peripheral.name ?? "unknown peripheral")

        guard let current = self.peripheral else {
            return
        }

        if(current == peripheral) {
            self.receiving = false
            self.peripheral = nil
        }

    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        peripherals.remove(peripheral)
        print("connection failed")
    }
    
}
// MARK: CBPeripheralDelegate
extension BluetoothService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
       if(characteristic.uuid == GATT.heartRateMeasurement) {
            let bpm = heartRate(from: characteristic)

           print(peripheral.name, bpm)
            onHeartRateReceived(bpm)
 
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
