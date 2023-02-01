//
//  AngularHierarchyView.swift
//  AngularHeirarchy
//
//  Created by Kai Quan Tay on 1/2/23.
//

import SwiftUI

struct AngularHierarchyView<Element: FanData>: View {
    var data: (Int, Element?) -> [Element]
    var shouldFocus: (Int, Element) -> Bool = { _, _ in true }

    @State var selectedElements: [Element] = []
    @State var layers: Int = 1
    @State var numberOfExteriorRings: Int = 3
    @State var distanceBetweenRings: CGFloat = 15
    @State var diameterOfBlurCircle: CGFloat = 220

    var body: some View {
        ZStack {
            ForEach(0..<layers, id: \.self) { layer in
                AngularHierarchyLayer(elements: elements(for: layer),
                                      originAngle: originAngle(for: layer),
                                      focusedElement: focusedElement(for: layer)) { focusAttempt in
                    shouldFocus(layer, focusAttempt)
                }
                .padding(padding(for: layer))
            }

            Circle()
                .frame(width: diameterOfBlurCircle, height: diameterOfBlurCircle)
                .foregroundColor(.init(uiColor: UIColor.systemBackground))
                .blur(radius: 15)
        }
    }

    func padding(for layer: Int) -> CGFloat {
        let numberOfExtraRings = max(0, layers - numberOfExteriorRings)
        let lastExtra: CGFloat = layer == layers-1 ? 5 : 0
        return distanceBetweenRings * CGFloat((layer - numberOfExtraRings) * -1) - lastExtra
    }

    func elements(for layer: Int) -> [Element] {
        if layer > 0 {
            return data(layer, selectedElements[layer-1])
        }
        return data(layer, nil)
    }

    func originAngle(for layer: Int) -> Angle {
        if layer == 0 { return .zero }

        let selectedElement = selectedElements[layer-1]
        let elements = elements(for: layer-1)
        guard let indexOfSelected = elements.firstIndex(of: selectedElement)
        else { return .zero }

        let startAngle: Angle = .degrees(180 * elements.progressBefore(indexOfSelected))
        let arcAngle: Angle = .degrees(180 * selectedElement.progress)

        return startAngle + (arcAngle/2)
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
        withAnimation(.easeOut(duration: 0.2)) {
            selectedElements.append(element)
            layers += 1
        }
    }

    func unfocusElement(index: Int) {
        let newElements = Array(selectedElements[0..<index])
        withAnimation(.easeOut(duration: 0.2)) {
            layers = newElements.count+1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                selectedElements = newElements
            }
        }
    }
}

struct AngularHierarchyView_Previews: PreviewProvider {
    static var previews: some View {
        AngularHierarchyView<ExampleFanData> { layer, _ in
            if layer == 0 {
                return ExampleFanData.examples
            } else if layer == 1 {
                return [
                    .init(color: .yellow,
                          name: "70%",
                          progress: 0.7),
                    .init(color: .cyan,
                          name: "30%",
                          progress: 0.3),
                ]
            }
            return []
        } shouldFocus: { layer, data in
            layer == 0
        }
        .frame(width: 300, height: 300)
    }
}
