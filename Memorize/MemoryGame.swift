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
    
    private var lastChoosen: Int?
    
    init(numberOfPairs: Int, createPairContent: (Int) -> CardContent) {
        cards = Array<Card>()
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
                cards[chosenIndex].isSeen = true
                cards[potentialMatch].isSeen = true
                lastChoosen = nil
            } else {
                for index in cards.indices {
                    cards[index].isFaceUp = false
                }
                lastChoosen = chosenIndex
            }
            cards[chosenIndex].isFaceUp.toggle()
        }
    }
    
    struct Card: Identifiable {
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        var isSeen: Bool = false
        var content: CardContent
        var id: Int
    }
}
