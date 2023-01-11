//
//  MemoryGame.swift
//  Memorize
//
//  Created by Eng, Nick on 1/1/23.
//

import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable {
    private(set) var cards: Array<Card>
    private(set) var score: Int = 0
    
    private var lastChoosen: Int? {
        get { cards.indices.filter({ cards[$0].isFaceUp }).oneAndOnly }
        set { cards.indices.forEach { cards[$0].isFaceUp = ($0 == newValue) } }
    }
    
    init(numberOfPairs: Int, createPairContent: (Int) -> CardContent) {
        cards = []
        for pairIndex in 0..<numberOfPairs {
            let content = createPairContent(pairIndex)
            cards.append(Card(content: content, id: pairIndex*2))
            cards.append(Card(content: content, id: pairIndex*2+1))
        }
        cards.shuffle()
    }
    
    mutating func choose(_ card: Card) {
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
           !cards[chosenIndex].isFaceUp,
           !cards[chosenIndex].isMatched {
            if let potentialMatch = lastChoosen {
                if cards[potentialMatch].content == cards[chosenIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatch].isMatched = true
                    score += 2
                } else if cards[chosenIndex].isSeen || cards[potentialMatch].isSeen {
                    score -= 1
                }
                cards[chosenIndex].isFaceUp = true
                cards[chosenIndex].isSeen = true
                cards[potentialMatch].isSeen = true
            } else {
                lastChoosen = chosenIndex
            }
        }
    }
    
    struct Card: Identifiable {
        var isFaceUp = false
        var isMatched = false
        var isSeen = false
        let content: CardContent
        let id: Int
    }
}

extension Array {
    var oneAndOnly: Element? {
        return self.count == 1 ? self.first : nil
    }
}
