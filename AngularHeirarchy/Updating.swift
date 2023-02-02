//
//  Updating.swift
//  Paymentz
//
//  Created by Kai Quan Tay on 1/2/23.
//

import SwiftUI

@propertyWrapper
struct Updating<Value>: DynamicProperty {
    var wrappedValue: Value { closure() }
    var closure: () -> Value

    init(wrappedValue: @escaping @autoclosure () -> Value) {
        self.closure = wrappedValue
    }
}
