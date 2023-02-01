//
//  FanData.swift
//  AngularHeirarchy
//
//  Created by Kai Quan Tay on 1/2/23.
//

import SwiftUI

protocol FanData: Identifiable, Hashable {
    var color: Color { get set }
    var name: String { get set }
    var progress: Double { get set }
}

extension Array where Element: FanData {
    func progressBefore(_ index: Int) -> Double {
        Array(self[0..<index]).reduce(Double(0)) { partialResult, data in
            partialResult + data.progress
        }
    }
}

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
