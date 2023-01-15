//
//  ContentView.swift
//  Set
//
//  Created by Eng, Nick on 1/14/23.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var game: SetGameViewModel
    
    var body: some View {
        VStack {
            AspectVGrid(items: game.cards, aspectRatio: 2/3, minimumWidth: 60) { card in
                CardView(card: card, isSelected: game.selectedCards.contains(card), isMatched: card.isMatched).padding(4).onTapGesture {
                            game.select(card)
                }
            }
            Spacer()
            HStack {
                Button {
                    game.newGame()
                } label: {
                    VStack {
                        Text("New Game")
                    }
                }
                Spacer()
                Button {
                    game.drawMoreCards()
                } label: {
                    VStack {
                        Text("Draw Cards")
                    }
                }.disabled(!game.canDraw)
                Spacer()
                Button {
                    game.cheat()
                } label: {
                    VStack {
                        Text("Cheat")
                    }
                }.disabled(!game.canCheat)
            }.padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static let game = SetGameViewModel()
    static var previews: some View {
        SetGameView(game: game).preferredColorScheme(.light)
        SetGameView(game: game).preferredColorScheme(.dark)
    }
}
