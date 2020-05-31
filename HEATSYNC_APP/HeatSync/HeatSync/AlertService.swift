//
//  AlertService.swift
//  HeatSync
//
//  Created by Nathan Tran on 5/26/20.
//  Copyright © 2020 Michael Marsella. All rights reserved.
//

import UIKit

class AlertService {
    func alert(title: String, body: String, buttonTitle: String) -> AlertViewController {
        let storyboard = UIStoryboard(name: "AlertStoryboard", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertVC") as! AlertViewController
        
        alertVC.alertTitle = title
        alertVC.alertBody = body
        alertVC.actionLabelTitle = buttonTitle
        
        return alertVC
    }
}

class TimerService {
    func alert(title: String, buttonTitle: String, completion: @escaping () -> Void) -> TimerViewController {
        let storyboard = UIStoryboard(name: "TimerStoryboard", bundle: .main)
        let timerVC = storyboard.instantiateViewController(withIdentifier: "TimerVC") as! TimerViewController
        
        timerVC.timerTitle = title
        timerVC.actionLabelTitle = buttonTitle
        timerVC.buttonAction = completion
        
        return timerVC
    }
}
