//
//  ColourShowView.swift
//  Colour Wheel
//
//  Created by Christian P on 12/6/20.
//  Copyright © 2020 Christian P. All rights reserved.
//

import SwiftUI

public struct ColorDisplayView: View {
    @Binding var rgbColor: RGB

    public init(rgb: Binding<RGB>) {
        _rgbColor = rgb
    }

    public var body: some View {
        /// The view that shows the selected colour.
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(
                Color(
                    red: Double(rgbColor.r),
                    green: Double(rgbColor.g),
                    blue: Double(rgbColor.b)
                )
            )
            /// The outline.
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("Outline"), lineWidth: 5)
            )
            /// The outer shadow.
            .shadow(color: Color("ShadowOuter"), radius: 18)
    }
}

struct ColourShowView_Previews: PreviewProvider {
    static var previews: some View {
        ColorDisplayView(rgb: .constant(RGB(r: 1, g: 1, b: 1)))
    }
}
