//
//  SetGameViewModel.swift
//  Set
//
//  Created by Eng, Nick on 1/14/23.
//

import SwiftUI

class SetGameViewModel: ObservableObject {
    typealias Card = SetGame<Shape, Color, Int, Shading>.Card

    @Published private var game = createSetGame() {
        didSet {
            // organize discard with last cards removed at the end of the array
            game.cards.prefix(game.cardsDealt).filter({ $0.isHidden }).forEach({ card in
                if let previousIndex = discarded.index(matching: card) {
                    discarded[previousIndex] = card
                } else {
                    discarded.append(card)
                }
            })
        }
    }
    @Published private(set) var discarded = Array<Card>()
    @Published private(set) var canCheat = true
    
    private static func createSetGame() -> SetGame<Shape, Color, Int, Shading> {
        return SetGame(
            shapes: [.diamond, .squiggle, .oval],
            colors: [.red, .green, .purple],
            numbers: [1, 2, 3],
            shadings: [.solid, .striped, .open]
        )
    }
    
    var allCards: Array<Card> {
        return game.cards
    }
    
    var cardsInPlay: Array<Card> {
        return game.cards.prefix(game.cardsDealt).filter({ !$0.isHidden })
    }
    
    var selectedCards: Set<Card> {
        return Set(game.selected.map({ game.cards[$0] }))
    }
    
    var cardsDealt: Int {
        return game.cardsDealt
    }
    
    var canDraw: Bool {
        return game.cardsDealt < game.cards.count
    }
    
    enum Shape: CaseIterable {
        case diamond, squiggle, oval
    }
    
    enum Shading: CaseIterable {
        case solid, striped, open
    }
    
    // MARK: - Intents
    
    func newGame() {
        game = SetGameViewModel.createSetGame()
        discarded = []
        canCheat = true
    }
    
    func select(_ card: Card) {
        game.select(card)
    }
    
    func drawMoreCards() {
        game.drawMoreCards()
    }
    
    func cheat() {
        canCheat = game.cheat()
    }
}