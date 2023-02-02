//
//  ContentView.swift
//  AngularHeirarchy
//
//  Created by Kai Quan Tay on 1/2/23.
//

import SwiftUI

struct ContentView: View {
    @State var selectedElements: [AnyFanData] = []

    var body: some View {
        AngularHierarchyView_Previews.AngularHierarchyViewWrapper()
//        AngularHierarchyView(selectedElements: $selectedElements) { _, _ in
//            return ExampleFanData.examples.typeErased()
//        }
//        .frame(width: 300, height: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
