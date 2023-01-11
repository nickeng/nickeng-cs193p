//
//  EmojiMemoryGameView.swift
//  Memorize
//
//  Created by Eng, Nick on 12/7/22.
//

import SwiftUI

struct EmojiMemoryGameView: View {
    @ObservedObject var game: EmojiMemoryGame
    
    var body: some View {
        VStack {
            HStack {
                Text(game.title).font(.title)
                Spacer()
                Text("Score: \(game.score)")
            }
            AspectVGrid(items: game.cards, aspectRatio: 2/3) { card in
                if card.isMatched && !card.isFaceUp {
                    Rectangle().opacity(0)
                } else {
                    CardView(card: card, gradientBackground: game.gradientBackground).padding(4).onTapGesture {
                            game.choose(card)
                        }
                }
            }
            Spacer()
            Button {
                game.reset()
            } label: {
                VStack {
                    Text("New Game")
                }
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

struct CardView: View {
    var card: EmojiMemoryGame.Card
    var gradientBackground: Gradient
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                let foregroundColor = gradientBackground.stops.first?.color
                if card.isFaceUp {
                    shape.fill().foregroundColor(.white)
                    shape.strokeBorder(LinearGradient(
                        gradient: gradientBackground,
                        startPoint: .top,
                        endPoint: .bottom
                    ), lineWidth: DrawingConstants.lineWidth)
                    Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: 110-90)).padding(6).foregroundColor(foregroundColor).opacity(0.5)
                    Text(card.content).font(font(fit: geometry.size))
                } else {
                    shape.fill(gradientBackground)
                }
            }
        })
    }
    
    private func font(fit size: CGSize) -> Font {
        Font.system(size: min(size.width, size.height) * DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 10
        static let lineWidth: CGFloat = 3
        static let fontScale: CGFloat = 0.8
    }
}

struct ContentView_Previews: PreviewProvider {
    static let game = EmojiMemoryGame()
    static var previews: some View {
        EmojiMemoryGameView(game: game).preferredColorScheme(.light)
        EmojiMemoryGameView(game: game).preferredColorScheme(.dark)
    }
}
