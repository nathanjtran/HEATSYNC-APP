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

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate, UIPickerViewDelegate {
    
    @IBOutlet weak var vestTempSliderVal: UILabel!  //value of slider for vest temp
        
    @IBOutlet weak var vestTempSlider: UISlider!    //the actual slider for vest input temp
        
    //label corresponding to the vest temperature reading from the arduino
    @IBOutlet weak var vestTempReading: UILabel!
        
    //label corresponding to the battery percentage
    @IBOutlet weak var batteryReading: UILabel!
    
    //label corresponding to cool time
    @IBOutlet weak var coolTimeReading: UITextField!
    
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
    
    //function that makes sure the app loads
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue:nil) //for bluetooth
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.systemTeal.cgColor,UIColor.white.cgColor]
        gradientLayer.locations = [0.20]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        coolTimeReading.text = "00:00:00"
        //For Cool Timer
        createTimePicker()
    }
    
    //Get Custom Alerts
    let alertService = AlertService()
    //Tap the HeatSync Logo to get an alert
    @IBAction func DidTapLogo(_ sender: Any) {
        let HeatSyncLogo = alertService.alert(title: "About HeatSync", body: "Make sure that bluetooth connectivity is on. Use the scoll features to set your desired vest temperature. You can manually turn on and off the vest with the power button. The battery at full charge lasts for about 1.5 to 3 hours depending on the cooling power. Stay Cool.", buttonTitle: "OK")
        present(HeatSyncLogo, animated: true)
    }
    
    //Cool Timer
    let timerService = TimerService()
    var seconds = 60
    var countDown = Timer()
    //Tap Cool Time
    @IBAction func DidTapCoolTime(_ sender: Any) {
//        let CoolTime = timerService.alert(title: "Cooling Timer", buttonTitle: "OK") {
//        }
//        present(CoolTime, animated: true)
        countDown.invalidate()
        coolTimeReading.text = "00:00:00"
        powerSwitch.isOn = false
    }
    
    //Alternative Cool Timer
    let picker = UIDatePicker()
    func createTimePicker() {
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        //Done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([done], animated: false)
        coolTimeReading.inputAccessoryView = toolbar
        coolTimeReading.inputView = picker
        //format picker
        picker.datePickerMode = .countDownTimer
    }
    func secondsToHMSColon (seconds: Int) -> String {
        let hours = "\(seconds/3600)"
        let minutes = "\((seconds % 3600) / 60)"
        let seconds = "\((seconds % 3600) % 60)"
        let hourStamp = hours.count > 1 ? hours : "0" + hours
        let minuteStamp = minutes.count > 1 ? minutes : "0" + minutes
        let secondStamp = seconds.count > 1 ? seconds : "0" + seconds
        return "\(hourStamp):\(minuteStamp):\(secondStamp)"
    }
    @objc func counter() {
        seconds -= 1
        coolTimeReading.text = secondsToHMSColon (seconds: seconds)
        if seconds < 1 {
            countDown.invalidate()
            coolTimeReading.text = "00:00:00"
            powerSwitch.isOn = false
        }
    }
    @objc func donePressed() {
        //Timer formatter
        let timeData = picker.countDownDuration
        seconds = Int(timeData)
        countDown.invalidate()
        countDown = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.counter), userInfo: nil, repeats: true)
        coolTimeReading.text = secondsToHMSColon (seconds: seconds)
        self.view.endEditing(true)
    }

    //function that is called when power switch is turned on
    @IBAction func updatePower(_ sender: Any) {
        if powerSwitch.isOn == true {
            //send bluetooth signal to turn on
            let val: UInt8 = 1  // not sure if this will work
            if powerChar != nil {
            sendVal(withCharacteristic: powerChar!, withValue: Data([val]))
            }
        }
        else{
            //send bluetooth signal to turn off
            let val: UInt8 = 0
            if powerChar != nil {
            sendVal(withCharacteristic: powerChar!, withValue: Data([val]))
            }
        }
    }
    
    //function called when vest temp slider is moved
    @IBAction func sendVestTemp(_ sender: Any) {
        vestTempSliderVal.text = String(Int(vestTempSlider.value)) + "°F"
        let val: UInt8 = UInt8(vestTempSlider.value)
        if vestChar != nil {
        sendVal(withCharacteristic: vestChar!, withValue: Data([val]))
        }
    }
    
    //function to send values over bluetooth
    private func sendVal(withCharacteristic characteristic: CBCharacteristic, withValue value:Data){
        //check if has write property
        if characteristic.properties.contains(.writeWithoutResponse) && peripheral != nil {
            peripheral.writeValue(value, for: characteristic, type: .withoutResponse)
        }
    }
    
    //function to handle updating all the fields, this is an example
    func recieveInfo(){
        vestTempReading.text = String(100)
        batteryReading.text = String(100)
        coolTimeReading.text = String(100)
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
            batteryReading.text = "N/A"
            coolTimeReading.text = "N/A"
            btRead.text = "N/A"
            self.peripheral = nil
            
            //scan again
            print("Central scanning for...")
            centralManager.scanForPeripherals(withServices: [ArduinoPeripheral.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
}

