//
//  AngularProgressElement.swift
//  Paymentz
//
//  Created by Kai Quan Tay on 30/1/23.
//

import SwiftUI

struct AngularProgressElement: View {
    /// The primary colour to fill the progress view
    @Updating var fillColour: Color
    /// The secondary colour to fill the progress view
    @Updating var secondaryColour: Color
    /// The thickness of the progress element
    @Updating var lineThickness: CGFloat
    /// The thickness of the border of the progress element
    @Updating var borderThickness: CGFloat
    /// How much spacing there is between the end of one element and the start of the next
    @Updating var spacing: CGFloat
    /// The angle that the progress element starts at
    @Updating var startAngle: Angle
    /// The amount of progress to show in the progress element, as a decimal (eg. 0.5 for 50%)
    @Updating var progress: CGFloat
    /// The label shown
    @Updating var label: String?

    init(fillColour: Color,
         secondaryColour: Color = .background.opacity(0.3),
         lineThickness: CGFloat,
         borderThickness: CGFloat = 3,
         spacing: CGFloat = .zero,
         startAngle: Angle,
         progress: CGFloat,
         label: String?) {
        self._fillColour = .init(wrappedValue: fillColour)
        self._secondaryColour = .init(wrappedValue: secondaryColour)
        self._lineThickness = .init(wrappedValue: lineThickness)
        self._borderThickness = .init(wrappedValue: borderThickness)
        self._spacing = .init(wrappedValue: spacing)
        self._startAngle = .init(wrappedValue: startAngle)
        self._progress = .init(wrappedValue: progress)
        self._label = .init(wrappedValue: label)
    }

    var body: some View {
        GeometryReader { geom in
            ZStack(alignment: .center) {
                Circle()
                    .trim(from: startTrim(size: geom.size),
                          to: endTrim(size: geom.size))
                    .stroke(fillColour,
                            style: .init(lineWidth: lineThickness,
                                         lineCap: .round))
                Circle()
                    .trim(from: startTrim(size: geom.size),
                          to: endTrim(size: geom.size))
                    .stroke(gradient(size: geom.size),
                            style: .init(lineWidth: lineThickness - borderThickness,
                                         lineCap: .round))
            }
            // before this rotation, the element starts at the 3-oclock position and goes clockwise
            // the rotation effect moves it so that the center of the element is at 3-oclock
            .rotationEffect(.degrees(-180 * progress))
            .overlay {
                // the label can then be added, offset to be on the outside
                // the label does its own math to make sure that its the right side up
                labelUI(size: geom.size)
            }
            // this undoes the previous rotation, moving it back to the 3-oclock position
            .rotationEffect(.degrees(180 * progress))
            // this moves it 180 degrees to the 9-oclock position (a more expected start point), and adds the
            // start angle to it.
            .rotationEffect(.degrees(180) + startAngle)
        }
    }

    @ViewBuilder
    func labelUI(size: CGSize) -> some View {
        Text(label ?? "")
            .font(.footnote)
            .bold()
            .foregroundColor(fillColour)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background {
                fillColour
                    .opacity(0.3)
                    .cornerRadius(5)
            }
            // undoes the rotation moving the center of the element to 3-oclock
            .rotationEffect(.degrees(-180 * progress))
            // matches the rotating to 9-oclock and adding start angle
            .rotationEffect(.degrees(-180) - startAngle)
            .offset(x: size.width / 2 + lineThickness * 2)
            .opacity(label == nil ? 0 : 1)
    }

    func startTrim(size: CGSize) -> CGFloat {
        let cumf = size.width * .pi
        return (lineThickness/2 + spacing) / cumf
    }

    func endTrim(size: CGSize) -> CGFloat {
        progress - startTrim(size: size)
    }

    func gradient(size: CGSize) -> some ShapeStyle {
        AngularGradient(colors: [fillColour, secondaryColour],
                        center: .center,
                        startAngle: .zero,
                        endAngle: .degrees(Double(360) * (progress)))
    }
}

struct AngularProgressElement_Previews: PreviewProvider {
    static let colours: [Color] = [
        .red,
        .orange,
        .yellow,
        .green,
        .blue,
        .purple,
        .pink
    ]

    static let totalSections: Int = 5

    static var previews: some View {
        VStack {
            ForEach(0..<4) { row in
                HStack {
                    ForEach(0..<3) { col in
                        ZStack {
                            AngularProgressElement(fillColour: colours[(row * 3 + col)%colours.count],
                                                   lineThickness: 20,
                                                   startAngle: .degrees(90),
                                                   progress: CGFloat(row) * 0.3 +
                                                              CGFloat(col) * 0.1,
                                                   label: nil)
                            Text("\(row * 30 + col * 10)")
                        }
                        .frame(width: 100, height: 100)
                        .padding(10)
                    }
                }
            }
        }

        ZStack {
            ForEach(0..<totalSections, id: \.self) { index in
                AngularProgressElement(fillColour: colours[index%colours.count],
                                       lineThickness: 20,
                                       spacing: 3,
                                       startAngle: .degrees(Double(360) *
                                                                      Double(index) /
                                                                      Double(totalSections)),
                                       progress: CGFloat(1)/CGFloat(totalSections),
                                       label: nil)
            }
        }.frame(width: 200, height: 200)

        AngularProgressElement(fillColour: .red,
                               lineThickness: 20,
                               spacing: 3,
                               startAngle: .degrees(90),
                               progress: 0.15,
                               label: "40%")
        .frame(width: 200, height: 200)
    }
}
