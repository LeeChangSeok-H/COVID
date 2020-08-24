//
//  BasicUtils.swift
//  COVID
//
//  Created by CHANGSEOK LEE on 2020/08/21.
//  Copyright © 2020 mangoslab. All rights reserved.
//
import Foundation

class SharedPreference {
    class func save (key: String, value: String) {
        let pref = UserDefaults.standard
        pref.setValue(value, forKey: key)
        pref.synchronize()
    }
    class func load (key: String) -> String {
        let pref = UserDefaults.standard
        if let value = pref.value(forKey: key) as? String {
            return value
        }
        return ""
    }
}
