//
//  AngularHierarchyView.swift
//  AngularHeirarchy
//
//  Created by Kai Quan Tay on 1/2/23.
//

import SwiftUI

struct AngularHierarchyView<Element: FanData>: View {
    var data: (Int, Element?) -> [Element]

    @State var selectedElements: [Element] = []
    @State var layers: Int = 1

    var body: some View {
        ZStack {
            ForEach(0..<layers, id: \.self) { layer in
                AngularHierarchyLayer(elements: elements(for: layer),
                                      focusedElement: focusedElement(for: layer))
                .padding(CGFloat(-15 * layer))
            }
        }
    }

    func elements(for layer: Int) -> [Element] {
        if layer > 0 {
            return data(layer, selectedElements[layer-1])
        }
        return data(layer, nil)
    }

    func focusedElement(for layer: Int) -> Binding<Element?> {
        .init {
            if layer >= selectedElements.count {
                return nil
            }
            return selectedElements[layer]
        } set: { newValue in
            if newValue == nil && layer < selectedElements.count {
                unfocusElement(index: layer)
            } else if let newValue, layer >= selectedElements.count {
                focusElement(element: newValue)
            }
        }
    }

    func focusElement(element: Element) {
        selectedElements.append(element)
        layers += 1
    }

    func unfocusElement(index: Int) {
        selectedElements = Array(selectedElements[0..<index])
        layers = selectedElements.count+1
    }
}

struct AngularHierarchyView_Previews: PreviewProvider {
    static var previews: some View {
        AngularHierarchyView { _, _ in
            return ExampleFanData.examples
        }
    }
}
