//
//  FanData.swift
//  AngularHeirarchy
//
//  Created by Kai Quan Tay on 1/2/23.
//

import SwiftUI

// MARK: Declaration
/// A protocol for data that the ``AngularProgressElement``, ``AngularHierarchyLayer``,
/// and ``AngularHierarchyView`` use to display information
protocol FanData: Identifiable, Hashable {
    var color: Color { get set }
    var name: String { get set }
    var progress: Double { get set }
}

// MARK: Array
extension Array where Element: FanData {
    /// The total progress of all the elements before a given index in the array
    func progressBefore(_ index: Int) -> Double {
        Array(self[0..<index]).reduce(Double(0)) { partialResult, data in
            partialResult + data.progress
        }
    }

    /// Type erases this array into an ``AnyFanData``
    func typeErased() -> [AnyFanData] {
        return self.map { item in
            AnyFanData(from: item)
        }
    }
}

// MARK: Type erasing
struct AnyFanData: FanData {
    var color: Color
    var name: String
    var progress: Double

    var id: AnyHashable
    var source: (any FanData)?

    init(color: Color,
         name: String,
         progress: Double,
         id: AnyHashable = UUID()) {
        self.color = color
        self.name = name
        self.progress = progress

        self.id = id
    }

    /// Creates an `AnyFanData` by erasing a given ``FanData``
    init<F: FanData>(from sourceData: F) {
        self.init(color: sourceData.color,
                  name: sourceData.name,
                  progress: sourceData.progress,
                  id: sourceData.id)
        self.source = sourceData
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(color)
        hasher.combine(name)
        hasher.combine(progress)
        hasher.combine(id)
        // ignore source
    }

    static func == (lhs: AnyFanData, rhs: AnyFanData) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension Color {
    /// SwiftUI Color for `UIColor.systemBackground`. Usually the opposite color to `Color.primary`
    static let background: Color = .init(uiColor: UIColor.systemBackground)
}

// MARK: Mock data
struct ExampleFanData: FanData {
    var color: Color
    var name: String
    var progress: Double

    var id = UUID()

    static var examples: [ExampleFanData] = [
        .init(color: .blue,
              name: "50%",
              progress: 0.5),
        .init(color: .pink,
              name: "30%",
              progress: 0.3),
        .init(color: .purple,
              name: "20%",
              progress: 0.2)
    ]
}
