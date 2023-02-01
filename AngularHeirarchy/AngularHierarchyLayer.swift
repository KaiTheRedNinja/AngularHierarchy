//
//  AngularHierarchyLayer.swift
//  AngularHeirarchy
//
//  Created by Kai Quan Tay on 1/2/23.
//

import SwiftUI

struct AngularHierarchyLayer<Element: FanData>: View {
    @Close var elements: [Element]

    @Close var focusRequirement: CGFloat = 30
    @Close var focusIncrease: CGFloat = 0.05

    @Close var showSelectedElementTitle: Bool = false
    @Close var lineThicknessWhenSelected: CGFloat = 5

//    @Close var originAngle: Angle = .zero
    @State private var expansion: CGFloat = 0

    @Binding var focusedElement: Element?

    var shouldAllowExpansion: (Element) -> Bool = { _ in true }

    @State private var draggedElement: Element?
    @State private var dragOffset: CGSize = .zero

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
            }
        }
        .onAppear {
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

    func fanDragGesture(element: Element) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if draggedElement != element {
                    withAnimation(.easeOut(duration: 0.2)) {
                        draggedElement = element
                    }
                }
                let newOffset = CGSize(point1: value.location,
                                       point2: value.startLocation)
                if newOffset.diagonalLength < 200 {
                    withAnimation {
                        dragOffset = newOffset
                    }
                }
            }
            .onEnded { _ in
                if dragOffset.diagonalLength < 30 || !shouldAllowExpansion(element) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        dragOffset = .zero
                        draggedElement = nil
                    }
                    return
                }
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
    }

    func startAngle(index: Int, element: Element) -> Angle {
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

        return .degrees(180 * elements.progressBefore(index) * expansion)
    }

    func progress(element: Element) -> CGFloat {
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

    func label(element: Element) -> String? {
        if let focusedElement, !(focusedElement == element && showSelectedElementTitle) {
            return nil
        }
        return element.name
    }
}

extension CGSize {
    init(point1: CGPoint, point2: CGPoint) {
        self.init(width: point1.x-point2.x,
                  height: point1.y-point2.y)
    }

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
        var focusedElement: ExampleFanData?

        var body: some View {
            AngularHierarchyLayer(elements: ExampleFanData.examples,
                                  showSelectedElementTitle: false,
                                  focusedElement: $focusedElement) { _ in
                true
            }
                .frame(width: 300, height: 300)
        }
    }
}
