//
//  AlertViewController.swift
//  HeatSync
//
//  Created by Nathan Tran on 5/26/20.
//  Copyright © 2020 Michael Marsella. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var BodyLabel: UILabel!
    @IBOutlet weak var ActionLabel: UIButton!
    @IBOutlet weak var CancelLabel: UIButton!
    
    var alertTitle = String()
    var alertBody = String()
    var actionLabelTitle = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ActionLabel.layer.cornerRadius = 17.0
        CancelLabel.layer.cornerRadius = 17.0
        
        setupView()
    }
    
    func setupView() {
        TitleLabel.text = alertTitle
        BodyLabel.text = alertBody
        ActionLabel.setTitle(actionLabelTitle, for: .normal)
    }
    
    @IBAction func DidTapCancel(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func DidTapAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

