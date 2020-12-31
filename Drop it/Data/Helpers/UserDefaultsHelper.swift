//
//  UserDefaultsHelper.swift
//  Drop it
//
//  Created by Sergio Bernal on 30/12/20.
//  Copyright © 2020 Sergio Bernal. All rights reserved.
//

import Foundation

@propertyWrapper struct UserDefaultsWrapper<Value> {
    let key: String
    let defaultValue: Value
    var storage: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}

struct UserDefaultsHelper {
    
    @UserDefaultsWrapper(key: "userIsLogged", defaultValue: false)
    static var userIsLogged: Bool
    
}
