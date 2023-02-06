//
//  Shake.swift
//  Set
//
//  Created by Eng, Nick on 2/5/23.
//

import SwiftUI

struct Shake: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit: CGFloat
    var position: CGFloat
    
    init(_ shake: Bool) {
        self.position = shake ? 1 : 0
        self.shakesPerUnit = shake ? 5 : 0
    }
    
    var animatableData: CGFloat {
        get { position }
        set { position = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(transform())
    }
    
    private func transform() -> CGAffineTransform {
        CGAffineTransform(translationX: transformAmount(), y: 0)
    }
    
    private func transformAmount() -> CGFloat {
        amount * sin(animatableData * .pi * shakesPerUnit)
    }
}

extension View {
    func shake(_ shake: Bool) -> some View {
        self.modifier(Shake(shake))
    }
}
