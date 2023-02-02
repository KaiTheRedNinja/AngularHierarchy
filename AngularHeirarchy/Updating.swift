//
//  Updating.swift
//  Paymentz
//
//  Created by Kai Quan Tay on 1/2/23.
//

import SwiftUI

/// A property wrapper type that reads and stays updated to a value owned by a source of truth.
///
/// Use a updating to create a one-way connection between a property that stores data, and a view that displays the data.
/// An updating connects a property to a source of truth stored elsewhere, instead of storing data directly, similar to Binding.
/// However, it does not have the ability to write to its source of truth.
///
/// ```swift
/// struct MyText: View {
///     @Updating var string: String
///
///     var body: some View {
///         Text(string)
///     }
/// }
/// ```
/// The parent view declares a property to hold the playing state, using the State property wrapper to indicate that this property is the value’s source of truth.
/// ```swift
/// struct TextEditingView: View {
///     @State private var string: String = "test"
///
///     var body: some View {
///         VStack {
///             TextField("Enter Text Here", $string)
///             MyText(string)
///         }
///     }
/// }
/// ```
///
/// When TextEditingView initializes MyText, it passes an updating of its state property into the button’s updating property.
/// Whenever the user changes the text, MyText updates its `string` state. This differs from state, as state only takes the
/// initial value and any updates done in the parent view would not be reflected in the child view.
///
/// # Implementation Details
/// Updating turns its `Value` into an `autoclosure` for `() -> Value`. In SwiftUI, whenever a value in a closure changes,
/// SwiftUI is forced to re-evaluate the closure, which allows updating to stay synced with its source of truth.
///
@propertyWrapper
struct Updating<Value>: DynamicProperty {
    var wrappedValue: Value { closure() }
    var closure: () -> Value

    init(wrappedValue: @escaping @autoclosure () -> Value) {
        self.closure = wrappedValue
    }
}
