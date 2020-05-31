//
//  TimerViewController.swift
//  HeatSync
//
//  Created by Nathan Tran on 5/28/20.
//  Copyright © 2020 Michael Marsella. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var ActionLabel: UIButton!
    @IBOutlet weak var CancelLabel: UIButton!
    @IBOutlet weak var TimerPicker: UIDatePicker!

    var timerTitle = String()
    var actionLabelTitle = String()
    var buttonAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ActionLabel.layer.cornerRadius = 17.0
        CancelLabel.layer.cornerRadius = 17.0
        
        setupView()
    }
    
    func setupView() {
        TitleLabel.text = timerTitle
        ActionLabel.setTitle(actionLabelTitle, for: .normal)
    }
    
    @IBAction func DidTapCancel(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func DidTapAction(_ sender: Any) {
        dismiss(animated: true)
        buttonAction?()
    }
//    @IBAction func datePickerChanged(_ sender: Any) {
//        //Change Date
//        let dateFormatter = DateFormatter()
//
//        dateFormatter.dateStyle = DateFormatter.Style.short
//        dateFormatter.timeStyle = DateFormatter.Style.short
//
//        let strDate = dateFormatter.string(from: datePicker.date)
//        dateLabel.text = strDate
//        }
        
}

//class TimerSelectViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        pickerView.delegate = self
//    }
//
//    @IBOutlet var pickerView: UIPickerView!
//    @IBAction func TimerPicker(_ sender: Any) {
//    }
//    var hour: Int = 0
//    var minutes: Int = 0
//    var seconds: Int = 0
//
//}
//     extension TimerSelectViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//         func numberOfComponents(in pickerView: UIPickerView) -> Int {
//             return 3
//         }
//
//         func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//             switch component {
//             case 0:
//                 return 25
//             case 1, 2:
//                 return 60
//             default:
//                 return 0
//             }
//         }
//
//         func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//             return pickerView.frame.size.width/3
//         }
//
//         func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//             switch component {
//             case 0:
//                 return "\(row) Hour"
//             case 1:
//                 return "\(row) Minute"
//             case 2:
//                 return "\(row) Second"
//             default:
//                 return ""
//             }
//         }
//         func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//             switch component {
//             case 0:
//                 hour = row
//             case 1:
//                 minutes = row
//             case 2:
//                 seconds = row
//             default:
//                 break;
//             }
//         }
//     }
