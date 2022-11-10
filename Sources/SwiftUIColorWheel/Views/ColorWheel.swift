//
//  ColorWheel.swift
//  Colour Wheel
//
//  Created by Christian P on 9/6/20.
//  Copyright © 2020 Christian P. All rights reserved.
//

import SwiftUI

/// The actual colour wheel view.
public struct ColorWheel: View {
    /// Draws at a specified radius.
    var radius: CGFloat

    /// The RGB colour. Is a binding as it can change and the view will update
    /// when it does.
    @Binding var rgbColor: RGB

    /// The brightness/value of the colour wheel
    @Binding var brightness: CGFloat

    public init(
        radius: CGFloat,
        rgb: Binding<RGB>,
        brightness: Binding<CGFloat>
    ) {
        self.radius = radius
        _rgbColor = rgb
        _brightness = brightness
        updateColor()
    }

    func updateColor() {
        DispatchQueue.main.async {
            rgbColor = HSV(
                h: rgbColor.hsv.h,
                s: rgbColor.hsv.s,
                v: self.brightness
            ).rgb
        }
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                /// The colour wheel. See the definition.
                CIHueSaturationValueGradientView(
                    radius: radius,
                    brightness: $brightness
                )
                /// Smoothing out of the colours.
                .blur(radius: 10)
                /// The outline.
                .overlay(
                    Circle()
                        .size(CGSize(width: self.radius, height: self.radius))
                        .stroke(Color("Outline"), lineWidth: 10)
                        /// Inner shadow.
                        .shadow(color: Color("ShadowInner"), radius: 8)
                )
                /// Clip inner shadow.
                .clipShape(
                    Circle()
                        .size(CGSize(width: self.radius, height: self.radius))
                )
                /// Outer shadow.
                .shadow(color: Color("ShadowOuter"), radius: 15)
                /// This is not required and actually makes the gradient less
                /// "accurate" but looks nicer. It's basically just a white
                /// radial gradient that blends the colours together nicer. We
                /// also slowly dissolve it as the brightness/value goes down.
                RadialGradient(
                    gradient: Gradient(
                        colors: [
                            Color.white.opacity(
                                0.8 * Double(brightness)
                            ),
                            .clear,
                        ]
                    ),
                    center: .center,
                    startRadius: 0,
                    endRadius: radius / 2 - 10
                )
                .blendMode(.screen)

                /// The little knob that shows selected colour.
                Circle()
                    .strokeBorder(.black, lineWidth: 1)
                    .frame(width: 10, height: 10)
                    .offset(x: (radius / 2 - 10) * rgbColor.hsv.s)
                    .rotationEffect(.degrees(-Double(rgbColor.hsv.h)))
            }
            /// The gesture so we can detect touches on the wheel.
            .gesture(
                DragGesture(
                    minimumDistance: 0,
                    coordinateSpace: .global
                )
                .onChanged { value in
                    /// Work out angle which will be the hue.
                    let y = geometry.frame(in: .global).midY - value.location.y
                    let x = value.location.x - geometry.frame(in: .global).midX

                    /// Use `atan2` to get the angle from the center point
                    /// then convert than into a 360 value with custom
                    /// function(find it in helpers).
                    let hue = atan2To360(atan2(y, x))

                    /// Work out distance from the center point which will
                    /// be the saturation.
                    let center = CGPoint(
                        x: geometry.frame(in: .global).midX,
                        y: geometry.frame(in: .global).midY
                    )

                    /// Maximum value of sat is 1 so we find the smallest of
                    /// 1 and the distance.
                    let saturation = min(
                        distance(center, value.location) / (radius / 2),
                        1
                    )

                    rgbColor = HSV(
                        h: hue,
                        s: saturation,
                        v: brightness
                    ).rgb
                }
            )
        }
        .frame(width: radius, height: radius)
    }
}

struct ColorWheel_Previews: PreviewProvider {
    static var previews: some View {
        ColorWheel(
            radius: 350,
            rgb: .constant(RGB(r: 1, g: 1, b: 1)),
            brightness: .constant(0)
        )
    }
}
