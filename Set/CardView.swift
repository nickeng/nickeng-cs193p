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
            if !isDealt {
                shape.fill().foregroundColor(.green)
            } else {
                shape.fill().foregroundColor(.white)
                if isMatched {
                    shape.fill().foregroundColor(.yellow).opacity(DrawingConstants.backgroundOpacity)
                }
                shape.strokeBorder(borderColor, lineWidth: DrawingConstants.lineWidth)
                VStack {
                    ForEach(0..<card.number, id: \.self) { _ in
                        cardShape.aspectRatio(3, contentMode: .fit)
                    }
                }
                .foregroundColor(card.color)
                .padding(10)
            }
        }
    }
    
    @ViewBuilder var cardShape: some View {
        switch card.shading {
            case .open: openShape
            case .solid: solidShape
            case .striped: stripedShape
        }
    }
    
    private var openShape: some View {
        ZStack {
            switch card.shape {
                case .diamond: Diamond().stroke(lineWidth: 2)
                case .oval: RoundedRectangle(cornerRadius: 1000).stroke(lineWidth: 2)
                case .squiggle: Rectangle().stroke(lineWidth: 2)
            }
        }
    }
    
    private var solidShape: some View {
        ZStack {
            switch card.shape {
                case .diamond: Diamond()
                case .oval: RoundedRectangle(cornerRadius: 1000)
                case .squiggle: Rectangle()
            }
        }
    }
    
    private var stripedShape: some View {
        ZStack {
            switch card.shape {
                case .diamond:
                    Diamond().stroke(lineWidth: 2)
                    Diamond().opacity(0.5)
                case .oval:
                    RoundedRectangle(cornerRadius: 1000).stroke(lineWidth: 2)
                    RoundedRectangle(cornerRadius: 1000).opacity(0.5)
                case .squiggle:
                    Rectangle().stroke(lineWidth: 2)
                    Rectangle().opacity(0.5)
            }
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
        SetGameViewModel.Card(shape: .diamond, color: .blue, number: 1, shading: .open),
        SetGameViewModel.Card(shape: .oval, color: .purple, number: 2, shading: .striped),
        SetGameViewModel.Card(shape: .squiggle, color: .orange, number: 3, shading: .solid)
    ]
    static var previews: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
            ForEach(cards) { card in
                CardView(card: card, isDealt: true, isSelected: false, isMatched: false).aspectRatio(2/3, contentMode: .fit)
                CardView(card: card, isDealt: true, isSelected: true, isMatched: false).aspectRatio(2/3, contentMode: .fit)
                CardView(card: card, isDealt: true, isSelected: true, isMatched: true).aspectRatio(2/3, contentMode: .fit)
            }
            ForEach(cards) { card in
                CardView(card: card, isDealt: false, isSelected: false, isMatched: false).aspectRatio(2/3, contentMode: .fit)
            }
            
        }.preferredColorScheme(.light)
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
            ForEach(cards) { card in
                CardView(card: card, isDealt: false, isSelected: false, isMatched: false).aspectRatio(2/3, contentMode: .fit)
                CardView(card: card, isDealt: true, isSelected: false, isMatched: false).aspectRatio(2/3, contentMode: .fit)
                CardView(card: card, isDealt: true, isSelected: true, isMatched: false).aspectRatio(2/3, contentMode: .fit)
            }
            ForEach(cards) { card in
                CardView(card: card, isDealt: false, isSelected: false, isMatched: false).aspectRatio(2/3, contentMode: .fit)
            }
            
        }.preferredColorScheme(.dark)
    }
}
