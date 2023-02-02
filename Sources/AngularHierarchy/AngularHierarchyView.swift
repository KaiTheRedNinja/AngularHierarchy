//
//  AngularHierarchyView.swift
//  AngularHeirarchy
//
//  Created by Kai Quan Tay on 1/2/23.
//

import SwiftUI

public struct AngularHierarchyView: View {
    /// The elements selected in the hierarchy, from innermost to outermost
    @Binding var selectedElements: [AnyFanData]
    /// The number of rings that will expand outwards before inner rings start to get smaller to make space
    @State var numberOfExteriorRings: Int = 3
    /// The distance between each ring. The outermost ring is 5px further to make the spacing consistent.
    @State var distanceBetweenRings: CGFloat = 15
    /// The distance from the center at which rings will start to fade away
    @State var diameterOfBlurCircle: CGFloat = 220
    /// The colour of the blur circle
    @State var blurColor: Color = .background

    /// The data source, taking in the layer and the parent FanData (if any), returns an array of data
    var data: (Int, AnyFanData?) -> [AnyFanData]
    /// If the element at the layer should be focused or not
    var shouldFocus: (Int, AnyFanData) -> Bool = { _, _ in true }

    /// Usually synced with `selectedElements.count`, this is used mainly for animating
    /// the layers to make them look smoother
    @State private var layers: Int = 1

    init(selectedElements: Binding<[AnyFanData]>,
         numberOfExteriorRings: Int = 3,
         distanceBetweenRings: CGFloat = 15,
         diameterOfBlurCircle: CGFloat = 220,
         blurColor: Color = .background,
         data: @escaping (Int, AnyFanData?) -> [AnyFanData],
         shouldFocus: @escaping (Int, AnyFanData) -> Bool = { _, _ in true }) {
        self._selectedElements = selectedElements
        self.numberOfExteriorRings = numberOfExteriorRings
        self.distanceBetweenRings = distanceBetweenRings
        self.blurColor = .background
        self.diameterOfBlurCircle = diameterOfBlurCircle
        self.data = data
        self.shouldFocus = shouldFocus
    }

    public var body: some View {
        ZStack {
            ForEach(0..<layers, id: \.self) { layer in
                AngularHierarchyLayer(elements: elements(for: layer),
                                      originAngle: originAngle(for: layer),
                                      focusedElement: focusedElement(for: layer)) { focusAttempt in
                    shouldFocus(layer, focusAttempt)
                }
                .padding(padding(for: layer))
            }

            // the blur circle
            Circle()
                .frame(width: diameterOfBlurCircle, height: diameterOfBlurCircle)
                .foregroundColor(blurColor)
                .blur(radius: 15)
        }
    }

    func padding(for layer: Int) -> CGFloat {
        let numberOfExtraRings = max(0, layers - numberOfExteriorRings)
        let lastExtra: CGFloat = layer == layers-1 ? 5 : 0
        return distanceBetweenRings * CGFloat((layer - numberOfExtraRings) * -1) - lastExtra
    }

    func elements(for layer: Int) -> [AnyFanData] {
        if layer > 0 && layer-1 < selectedElements.count {
            return data(layer, selectedElements[layer-1])
        }
        return data(layer, nil)
    }

    /// Determines what the Angle is that the layer animates starting from. Defaults to zero degrees.
    func originAngle(for layer: Int) -> Angle {
        if layer == 0 || layer-1 >= selectedElements.count { return .zero }

        let selectedElement = selectedElements[layer-1]
        let elements = elements(for: layer-1)
        guard let indexOfSelected = elements.firstIndex(of: selectedElement)
        else { return .zero }

        let startAngle: Angle = .degrees(180 * elements.progressBefore(indexOfSelected))
        let arcAngle: Angle = .degrees(180 * selectedElement.progress)

        return startAngle + (arcAngle/2)
    }

    /// Gets a binding for the focused element at a specified layer
    func focusedElement(for layer: Int) -> Binding<AnyFanData?> {
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

    /// Focuses the given element and animates the changes
    func focusElement(element: AnyFanData) {
        withAnimation(.easeOut(duration: 0.2)) {
            selectedElements.append(element)
            layers += 1
        }
    }

    /// Unfocuses the element at the given layer and all layers above, and animates the changes
    /// First gets rid of the layer, and then removes the element.
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
        AngularHierarchyViewWrapper()
    }

    struct AngularHierarchyViewWrapper: View {
        var secondLayer: [ExampleFanData] = [
            .init(color: .yellow,
                  name: "70%",
                  progress: 0.7),
            .init(color: .cyan,
                  name: "30%",
                  progress: 0.3),
        ]

        @State var selectedElements: [AnyFanData] = []

        var body: some View {
            #if os(iOS)
            List {
                hierarchy

                ForEach(selectedElements) { element in
                    Text(element.name)
                }
            }
            .listStyle(.inset)
            #elseif os(macOS)
            hierarchy
                .frame(width: 600, height: 600)
            #endif
        }

        var hierarchy: some View {
            HStack {
                Spacer()
                AngularHierarchyView(selectedElements: $selectedElements) { layer, _ in
                    if layer == 0 {
                        return ExampleFanData.examples.typeErased()
                    } else if layer < 5 {
                        return secondLayer.typeErased()
                    }
                    return []
                } shouldFocus: { layer, _ in
                    layer < 4
                }
                .frame(width: 300, height: 300)
                .padding(.bottom, -120)
                .padding(.top, 20)
                Spacer()
            }
        }
    }
}
