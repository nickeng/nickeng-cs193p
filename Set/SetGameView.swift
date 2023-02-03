//
//  ContentView.swift
//  Set
//
//  Created by Eng, Nick on 1/14/23.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var game: SetGameViewModel
    
    @Namespace private var dealingNamespace
    
    @State private var dealt = Set<UUID>()
    
    private func deal(_ card: SetGameViewModel.Card) {
        dealt.insert(card.id)
    }
    
    private func isInDeck(_ card: SetGameViewModel.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func dealAnimation(for card: SetGameViewModel.Card) -> Animation {
        var delay = 0.0
        if let index = game.allCards.firstIndex(where: { $0.id == card.id }) {
            delay = Double(game.cardsDealt > 12 ? index % 3 : index) * CardConstants.dealDelay
            
        }
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
    
    var body: some View {
        VStack {
            cardsInPlay
            HStack {
                deck
                Spacer()
                Button("New Game") {
                    game.newGame()
                }
                Spacer()
                Button("Cheat") {
                    withAnimation {
                        game.cheat()
                    }
                }.disabled(!game.canCheat)
                Spacer()
                discardPile
            }
            .padding(.horizontal)
            .zIndex(-1)
        }
        .padding()
    }
    
    var cardsInPlay: some View {
        AspectVGrid(items: game.cardsInPlay, aspectRatio: CardConstants.aspectRatio, minimumWidth: CardConstants.minimumWidth) { card in
            if isInDeck(card) {
                Color.clear
            } else {
                CardView(card: card, isDealt: true, isSelected: game.selectedCards.contains(card), isMatched: card.isMatched, isNotMatched: (!card.isMatched && game.selectedCards.count == 3))
                    .padding(4)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .zIndex(zIndex(of: card))
                    .onTapGesture {
                        withAnimation {
                            game.select(card)
                        }
                    }
            }
        }
    }
    
    var deck: some View {
        CardDeck(items: game.allCards.filter(isInDeck)) { card in
            if game.cardsInPlay.contains(card) {
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .zIndex(zIndex(of: card))
                    .onAppear {
                        withAnimation(dealAnimation(for: card)) {
                            deal(card)
                        }
                    }
            } else {
                CardView(card: card)
                    .zIndex(zIndex(of: card))
            }
        }
        .frame(width: CardConstants.deckWidth, height: CardConstants.deckHeight)
        .onTapGesture {
            withAnimation {
                game.drawMoreCards()
            }
        }
        
    }
    
    var discardPile: some View {
        CardDeck(items: game.discarded) { card in
            CardView(card: card, isDealt: true)
                .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                .zIndex(zIndex(of: card, invert: true))
        }
        .frame(width: CardConstants.deckWidth, height: CardConstants.deckHeight)
    }
    
    private func zIndex(of card: SetGameViewModel.Card, invert: Bool = false) -> Double {
        let index = Double(game.allCards.firstIndex(where: { $0.id == card.id }) ?? 0)
        return invert ? index : 100.0 - index
    }
    
    private struct CardConstants {
        static let aspectRatio: CGFloat = 2/3
        static let minimumWidth: CGFloat = 60
        static let dealDuration: Double = 0.5
        static let dealDelay: Double = 0.1
        static let deckHeight: CGFloat = 90
        static let deckWidth: CGFloat = deckHeight * aspectRatio
    }
}

struct CardDeck<Item, ItemView>: View where ItemView: View, Item: Identifiable {
    var items: [Item]
    var content: (Item) -> ItemView
    
    init(items: [Item], @ViewBuilder content: @escaping (Item) -> ItemView) {
        self.items = items
        self.content = content
    }
    
    var body: some View {
        ZStack {
            ForEach(items) { item in
                content(item)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let game = SetGameViewModel()
    static var previews: some View {
        SetGameView(game: game).preferredColorScheme(.light)
        SetGameView(game: game).preferredColorScheme(.dark)
    }
}
