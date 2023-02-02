//
//  AngularHierarchyLayer.swift
//  AngularHeirarchy
//
//  Created by Kai Quan Tay on 1/2/23.
//

import SwiftUI
import Updating

struct AngularHierarchyLayer: View {
    /// The elements to show in the layer
    @Updating var elements: [AnyFanData]

    /// The number of pixels away from a segment's original position it needs to be dragged to be focused
    @Updating var focusRequirement: CGFloat = 30
    /// The amount that the segment increases by when being dragged past the focusRequirement. Calculated by 180 x focusIncrease, in degrees.
    @Updating var focusIncrease: CGFloat = 0.05

    /// If the view should display the title of the currently focused element
    @Updating var showSelectedElementTitle: Bool = false
    /// The thickness of the segment when it is selected
    @Updating var lineThicknessWhenSelected: CGFloat = 15

    /// The angle that the layer animates from on appear
    @Updating var originAngle: Angle = .zero
    @State private var expansion: CGFloat = 0

    /// The element that is currently focused
    @Binding var focusedElement: AnyFanData?

    /// If a given element should be allowed to be focused
    var shouldAllowExpansion: (AnyFanData) -> Bool = { _ in true }

    @State private var draggedElement: AnyFanData?
    @State private var dragOffset: CGSize = .zero

    init(elements: [AnyFanData],
         focusRequirement: CGFloat = 30,
         focusIncrease: CGFloat = 0.05,
         showSelectedElementTitle: Bool = false,
         lineThicknessWhenSelected: CGFloat = 15,
         originAngle: Angle = .zero,
         focusedElement: Binding<AnyFanData?>,
         shouldAllowExpansion: @escaping (AnyFanData) -> Bool) {
        self._elements = .init(wrappedValue: elements)
        self._focusRequirement = .init(wrappedValue: focusRequirement)
        self._focusIncrease = .init(wrappedValue: focusIncrease)
        self._showSelectedElementTitle = .init(wrappedValue: showSelectedElementTitle)
        self._lineThicknessWhenSelected = .init(wrappedValue: lineThicknessWhenSelected)
        self._originAngle = .init(wrappedValue: originAngle)
        self._focusedElement = focusedElement
        self.shouldAllowExpansion = shouldAllowExpansion
    }

    var body: some View {
        ZStack {
            ForEach(Array(elements.enumerated()), id: \.element) { index, element in
                AngularProgressElement(fillColour: element.color,
                                       lineThickness: focusedElement == element ?
                                            lineThicknessWhenSelected : 15,
                                       borderThickness: 3,
                                       spacing: 3,
                                       startAngle: startAngle(index: index,
                                                              element: element),
                                       progress: progress(element: element),
                                       label: label(element: element))
                .offset(element == draggedElement ? dragOffset : .zero)
                .gesture(fanDragGesture(element: element))
                .onTapGesture {
                    toggleFocus(element: element)
                }
            }
        }
        .onAppear {
            // Animate the segments appearing from originAngle
            withAnimation(.easeOut(duration: 0.2)) {
                expansion = 1
            }
        }
        .onDisappear() {
            withAnimation(.easeOut(duration: 0.2)) {
                expansion = 0
            }
        }
    }

    /// Creates a gesture for an `AngularProgressElement` given an `AnyFanData`
    func fanDragGesture(element: AnyFanData) -> some Gesture {
        DragGesture()
            .onChanged { value in
                // mark the element as the dragged element if it isn't already
                if draggedElement != element {
                    withAnimation(.easeOut(duration: 0.2)) {
                        draggedElement = element
                    }
                }
                let newOffset = CGSize(point1: value.location,
                                       point2: value.startLocation)
                // if the new size is within 200 pixels of the center, move it there.
                if newOffset.diagonalLength < 200 {
                    withAnimation {
                        dragOffset = newOffset
                    }
                }
            }
            .onEnded { _ in
                // If the element has not been dragged far enough or it isn't allowed to expand, reset.
                if dragOffset.diagonalLength < focusRequirement || !shouldAllowExpansion(element) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        dragOffset = .zero
                        draggedElement = nil
                    }
                    return
                }
                // else, focus it
                toggleFocus(element: element)
            }
    }

    /// Focuses or unfocuses a given element, and animates the change
    func toggleFocus(element: AnyFanData) {
        guard shouldAllowExpansion(element) else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            dragOffset = .zero
            draggedElement = nil
            if focusedElement == element {
                focusedElement = nil
            } else {
                focusedElement = element
            }
        }
    }

    /// Calculates the angle that the fan for a given element should start
    func startAngle(index: Int, element: AnyFanData) -> Angle {
        if let draggedElement,
            draggedElement == element,
            shouldAllowExpansion(element),
            dragOffset.diagonalLength > focusRequirement {
            return .degrees(180 * (elements.progressBefore(index) - focusIncrease))
        } else if let focusedElement,
                  let firstIndex = elements.firstIndex(of: focusedElement) {
            if focusedElement == element {
                return .zero
            } else if index < firstIndex {
                return .zero
            } else if index > firstIndex {
                return .degrees(180)
            }
        }

        let start: Angle = .degrees(180 * elements.progressBefore(index) * expansion)

        let distanceFromOrigin = originAngle - start

        return start + distanceFromOrigin * (1 - expansion)
    }

    /// Calculates the amount of the graph (as a decimal, 1 being 100%) that the element should take up
    func progress(element: AnyFanData) -> CGFloat {
        if let draggedElement,
            draggedElement == element,
            shouldAllowExpansion(element),
            dragOffset.diagonalLength > focusRequirement {
            return (0.5 * element.progress) + focusIncrease
        } else if let focusedElement {
            if focusedElement == element {
                return 0.5
            } else {
                return 0
            }
        }

        return 0.5 * element.progress * expansion
    }

    /// Calculates the label of the element
    func label(element: AnyFanData) -> String? {
        if let focusedElement, !(focusedElement == element && showSelectedElementTitle) {
            return nil
        }
        return element.name
    }
}

extension CGSize {
    /// Initialises a CGSize from the difference between two points
    init(point1: CGPoint, point2: CGPoint) {
        self.init(width: point1.x-point2.x,
                  height: point1.y-point2.y)
    }

    /// The diagonal length between two opposite corners of the CGSize. Always positive.
    var diagonalLength: CGFloat {
        return sqrt(pow(self.width, 2) + pow(self.height, 2))
    }
}

struct AngularHierarchyLayer_Previews: PreviewProvider {
    static var previews: some View {
        AngularHierarchyLayerWrapper()
    }

    struct AngularHierarchyLayerWrapper: View {
        @State
        var focusedElement: AnyFanData?

        var body: some View {
            AngularHierarchyLayer(elements: ExampleFanData.examples.typeErased(),
                                  showSelectedElementTitle: false,
                                  originAngle: .degrees(90),
                                  focusedElement: $focusedElement) { _ in
                true
            }
                .frame(width: 300, height: 300)
        }
    }
}
