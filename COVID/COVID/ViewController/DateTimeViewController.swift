//
//  DateTimeViewController.swift
//  COVID
//
//  Created by CHANGSEOK LEE on 2020/08/23.
//  Copyright © 2020 mangoslab. All rights reserved.
//

import Foundation
import UIKit

protocol SendDataDelegate {
    func sendData(data: String)
}

class DateTimeViewController: UIViewController {
    @IBOutlet weak var dateTime: UIDatePicker!
    
    let dateformatter = DateFormatter()
    var date : String = ""
    
    var dailyViewController : DailyStateViewController? = DailyStateViewController()
    
    var delegate : SendDataDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateformatter.dateFormat = "yyyyMMdd"
        date = dateformatter.string(from: dateTime.date)
    }
    
    @IBAction func changeDatePicker(_ sender: Any) {
        date = dateformatter.string(from: dateTime.date)
    }
    @IBAction func actionForComplete(_ sender: Any) {
        SharedPreference.save(key: SharedPreferenceKey.SAVE_SELECTED_DATE, value: date)
        navigationController?.popViewController(animated: true)
    }
}
