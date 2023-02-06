//
//  Dance.swift
//  Set
//
//  Created by Eng, Nick on 2/5/23.
//

import SwiftUI

struct Dance: GeometryEffect {
    var offsetValue: CGFloat
    var shakesPerUnit: CGFloat
    
    init(_ dance: Bool) {
        self.offsetValue = dance ? 1 : 0
        self.shakesPerUnit = dance ? 5 : 0
    }
    
    var animatableData: Double {
        get { offsetValue }
        set { offsetValue = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(transform(size))
    }
    
    private func transform(_ size: CGSize) -> CGAffineTransform {
        // center the rotation
        CGAffineTransform(translationX: size.width*0.5, y: size.height*0.5)
            .rotated(by: CGFloat(angle()))
            .translatedBy(x: -size.width*0.5, y: -size.height*0.5)
    }
    
    private func angle() -> CGFloat {
        .pi * sin(animatableData * .pi * shakesPerUnit) / 6
    }
}

extension View {
    func dance(_ dance: Bool) -> some View {
        self.modifier(Dance(dance))
    }
}
