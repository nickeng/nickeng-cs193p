//
//  ContentView.swift
//  Memorize
//
//  Created by Eng, Nick on 12/7/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var game: EmojiMemoryGame
    
    var body: some View {
        VStack {
            HStack {
                Text(game.title).font(.title)
                Spacer()
                Text("Score: \(game.score)")
            }
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 6) {
                    ForEach(game.cards) { card in
                        CardView(card: card, gradientBackground: game.gradientBackground).aspectRatio(2/3, contentMode: .fit)
                            .onTapGesture {
                                game.choose(card)
                            }
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
    var card: MemoryGame<String>.Card
    var gradientBackground: Gradient
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 20)
            if card.isFaceUp {
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(LinearGradient(
                    gradient: gradientBackground,
                    startPoint: .top,
                    endPoint: .bottom
                ), lineWidth: 3)
                Text(card.content).font(.largeTitle)
            } else if card.isMatched {
                shape.opacity(0)
            } else {
                shape.fill(gradientBackground)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let game = EmojiMemoryGame()
    static var previews: some View {
        ContentView(game: game).preferredColorScheme(.light)
        ContentView(game: game).preferredColorScheme(.dark)
    }
}
