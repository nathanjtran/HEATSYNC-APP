//
//  ViewController.swift
//  TempControl2
//
//  Created by Michael Marsella on 4/24/20.
//  Copyright © 2020 Michael Marsella. All rights reserved.
// bluetooth tutorial and code from https://www.freecodecamp.org/news/ultimate-how-to-bluetooth-swift-with-hardware-in-20-minutes/
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    
    @IBOutlet weak var vestTempSliderVal: UILabel!  //value of slider for vest temp
        
    @IBOutlet weak var vestTempSlider: UISlider!    //the actual slider for vest input temp
        
    //label corresponding to the vest temperature reading from the arduino
    @IBOutlet weak var vestTempReading: UILabel!
        
    //label corresponding to the battery percentage
    @IBOutlet weak var batteryReading: UILabel!
    
    //label corresponding to heart rate
    @IBOutlet weak var heartReading: UILabel!
    
    //label corresponding to the cool state
    @IBOutlet weak var coolStateReading: UILabel!
    
    //label corresponding to cool time
    @IBOutlet weak var coolReading: UILabel!
    
    //label corresponding to bluetooth status
    @IBOutlet weak var btRead: UILabel!
    
    //the actual power switch
    @IBOutlet weak var powerSwitch: UISwitch!
    
    //manager for bluetooth
    private var centralManager: CBCentralManager!
    
    //peripherial to be connected (i.e arduino)
    private var peripheral: CBPeripheral!
    
    //bluetooth characteristic variables to be sent
    private var powerChar: CBCharacteristic?
    private var vestChar: CBCharacteristic?
    private var pelChar: CBCharacteristic?
    
//    //For Timer
//    @IBOutlet weak var countingLabel: UILabel!
//    @IBOutlet weak var datePicker: UIDatePicker!
//    var NStimer = Timer()
    
    //function that makes sure the app loads
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue:nil) //for bluetooth
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.systemBlue.cgColor,UIColor.white.cgColor]
        gradientLayer.locations = [0.20]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //Get Custom Alerts
    let alertService = AlertService()
    //Tap the HeatSync Logo to get an alert
    @IBAction func DidTapLogo(_ sender: Any) {
        let HeatSyncLogo = alertService.alert(title: "About HeatSync", body: "Make sure that bluetooth connectivity is on. Use the scoll features to set your desired vest. You can manually turn on and off the vest with the power button. The battery at full charge lasts for about 1 to 3.5 hours depending on cooling power. Stay Cool.", buttonTitle: "OK")
        present(HeatSyncLogo, animated: true)
    }
    
    //Cool Timer
    let timerService = TimerService()
    //Tap Cool Time
    @IBAction func DidTapCoolTime(_ sender: Any) {
        let CoolTime = timerService.alert(title: "Cooling Timer", buttonTitle: "OK") {
        }
        present(CoolTime, animated: true)
    }
    
    //Cool State
    let stateService = AlertService()
    //Tap Cool State
    @IBAction func DidTapState(_ sender: Any) {
        let CoolState = stateService.alert(title: "Cool State", body: "These are the 5 levels of the cooling state: LESS, MORE, VERY, SUPER, and EXTREME.", buttonTitle: "OK")
//        if vestTempSlider.value >= 30 && vestTempSlider.value <= 40 {
//                coolStateReading.text = "EXTREME"
//        }
//        if vestTempSlider.value > 40 && vestTempSlider.value <= 50 {
//                coolStateReading.text = "SUPER"
//        }
//        if vestTempSlider.value > 50 && vestTempSlider.value <= 60 {
//                coolStateReading.text = "VERY"
//        }
//        if vestTempSlider.value > 60 && vestTempSlider.value <= 70 {
//                coolStateReading.text = "MORE"
//        }
//        if vestTempSlider.value > 70 && vestTempSlider.value <= 80 {
//                coolStateReading.text = "LESS"
//        }
        present(CoolState, animated: true)
    }
    
    
    //function that is called when power switch is turned on
    @IBAction func updatePower(_ sender: Any) {
        if powerSwitch.isOn {
//            //send bluetooth signal to turn on
//            let val: UInt8 = 1  // not sure if this will work
//            sendVal(withCharacteristic: powerChar!, withValue: Data([val]))
//        }
//        else{
//            //send bluetooth signal to turn off
//            let val: UInt8 = 0
//            sendVal(withCharacteristic: powerChar!, withValue: Data([val]))
        }
    }
    
    //function called when vest temp slider is moved
    @IBAction func sendVestTemp(_ sender: Any) {
        vestTempSliderVal.text = String(Int(vestTempSlider.value)) + "°F"
//        let val: UInt8 = UInt8(vestTempSlider.value)
//        sendVal(withCharacteristic: vestChar!, withValue: Data([val]))
        if vestTempSlider.value >= 30 && vestTempSlider.value <= 40 {
                coolStateReading.text = "EXTREME"
        }
        if vestTempSlider.value > 40 && vestTempSlider.value <= 50 {
                coolStateReading.text = "SUPER"
        }
        if vestTempSlider.value > 50 && vestTempSlider.value <= 60 {
                coolStateReading.text = "VERY"
        }
        if vestTempSlider.value > 60 && vestTempSlider.value <= 70 {
                coolStateReading.text = "MORE"
        }
        if vestTempSlider.value > 70 && vestTempSlider.value <= 80 {
                coolStateReading.text = "LESS"
        }
    }
    
    //function to send values over bluetooth
    private func sendVal(withCharacteristic characteristic: CBCharacteristic, withValue value:Data){
        //check if has write property
        if characteristic.properties.contains(.writeWithoutResponse) && peripheral != nil {
            peripheral.writeValue(value, for: characteristic, type: .withoutResponse)
        }
        else{
            //
        }
    }
    
    //function to handle updating all the fields, this is an example
    func recieveInfo(){
        vestTempReading.text = String(100)
        batteryReading.text = String(100)
        heartReading.text = String(100)
        coolReading.text = String(100)
        
    }
    
    //If bluetooth on start scanning
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state updated")
        if central.state != .poweredOn{
            print("Central is not powered on")
            btRead.text = "OFF"
        }
        else {
            print("Central is scanning for...")
            btRead.text = "ON"
            centralManager.scanForPeripherals(withServices: [ArduinoPeripheral.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    //bluetooth function
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        
        self.centralManager.stopScan()  //found, so stop scanning
        
        //copy peripheral instance
        self.peripheral = peripheral
        self.peripheral.delegate = self
        
        //connect
        self.centralManager.connect(self.peripheral, options: nil)
    }
    
    //bluetooth function
    //if connect successfully, check if it is the right device
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
        if peripheral == self.peripheral {
            print("Connected to arduino")
            peripheral.discoverServices([ArduinoPeripheral.serviceUUID])
        }
    }
    
    //bluetooth function
    //handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices eroor: Error?){
        if let services = peripheral.services {
            for service in services {
                if service.uuid == ArduinoPeripheral.serviceUUID{
                    print("Arduino bluetooth service found")
                    
                    //start discovery of characteristics
                    peripheral.discoverCharacteristics([ArduinoPeripheral.editUUID],for: service)
                    //this is where you will add other characteristics from Arduino UUID
                }
            }
        }
    }
    
    //handles discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                
                //this is example, basically saying if the UUID for a characteristic is found, connect to bluetooth characteristc
                if characteristic.uuid == ArduinoPeripheral.editUUID {
                    vestChar = characteristic //example
                    vestTempSlider.isEnabled = true
                    powerSwitch.isEnabled = true
                    print("Modify characteristic found")
                }
            }
        }
    }
    
    //bluetooth function
    //handler if disconnected from arduino
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?){
        
        if peripheral == self.peripheral {
            print("Disconnected")
            vestTempSlider.value = 0
            vestTempReading.text = "N/A"
            vestTempSliderVal.text = "0"
            batteryReading.text="N/A"
            coolReading.text = "N/A"
            heartReading.text = "N/A"
            btRead.text = "N/A"
            self.peripheral = nil
            
            //scan again
            print("Central scanning for...")
            centralManager.scanForPeripherals(withServices: [ArduinoPeripheral.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
}

