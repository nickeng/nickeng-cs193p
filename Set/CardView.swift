//
//  CardView.swift
//  Set
//
//  Created by Eng, Nick on 1/14/23.
//

import SwiftUI

struct CardView: View {
    var card: SetGameViewModel.Card
    var isDealt: Bool = false
    var isSelected: Bool = false
    var isMatched: Bool = false
    var isNotMatched: Bool = false
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
            if isDealt {
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
            } else {
                shape.fill()
            }
            if isMatched {
                Color.yellow.opacity(DrawingConstants.backgroundOpacity).mask(shape)
            }
            VStack {
                ForEach(0..<card.number, id: \.self) { _ in
                    shadedShape.aspectRatio(3, contentMode: .fit)
                }
            }
            .opacity(isDealt ? 1 : 0)
            .foregroundColor(card.color)
            .padding(10)
        }
        .foregroundColor(borderColor)
        .shake(isNotMatched)
        .dance(isMatched)
        .animation(.linear(duration: 1), value: isMatched)
    }
    
    @ViewBuilder var shadedShape: some View {
        ZStack {
            switch card.shading {
            case .open: shape.stroke(lineWidth: 2)
            case .solid: shape
            case .striped:
                StripedView().mask(shape)
                shape.stroke(lineWidth: 2)
            }
        }
    }
    
    private var shape: some Shape {
        switch card.shape {
            case .diamond: return AnyShape(Diamond())
            case .oval: return AnyShape(Capsule())
            case .squiggle: return AnyShape(Squiggle())
        }
    }
    
    private var borderColor: Color {
        if !isSelected {
            return .gray
        } else if isNotMatched {
            return .red
        }
        return .yellow
    }
    
    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 10
        static let lineWidth: CGFloat = 3
        static let backgroundOpacity: CGFloat = 0.3
    }
}

struct CardView_Previews: PreviewProvider {
    static let cards = [
        SetGameViewModel.Card(id: 0, shape: .diamond, color: .blue, number: 1, shading: .open),
        SetGameViewModel.Card(id: 0, shape: .oval, color: .purple, number: 2, shading: .striped),
        SetGameViewModel.Card(id: 0, shape: .squiggle, color: .orange, number: 3, shading: .solid)
    ]
    static var previews: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
            ForEach(cards) { card in
                CardView(card: card, isDealt: true).aspectRatio(2/3, contentMode: .fit)
                CardView(card: card, isDealt: true, isSelected: true).aspectRatio(2/3, contentMode: .fit)
                CardView(card: card, isDealt: true, isSelected: true, isMatched: true).aspectRatio(2/3, contentMode: .fit)
            }
            ForEach(cards) { card in
                CardView(card: card).aspectRatio(2/3, contentMode: .fit)
            }
            
        }.preferredColorScheme(.light)
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
            ForEach(cards) { card in
                CardView(card: card, isDealt: true).aspectRatio(2/3, contentMode: .fit)
                CardView(card: card, isDealt: true, isSelected: true).aspectRatio(2/3, contentMode: .fit)
                CardView(card: card, isDealt: true, isSelected: true, isMatched: true).aspectRatio(2/3, contentMode: .fit)
            }
            ForEach(cards) { card in
                CardView(card: card).aspectRatio(2/3, contentMode: .fit)
            }
            
        }.preferredColorScheme(.dark)
    }
}
