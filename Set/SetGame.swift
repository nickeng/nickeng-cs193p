//
//  SetGame.swift
//  Set
//
//  Created by Eng, Nick on 1/14/23.
//

import Foundation

struct SetGame<Shape: Hashable, Color: Hashable, Number: Hashable, Shading: Hashable> {
    private(set) var cards: Array<Card>
    private(set) var selected: Set<Int> = []
    private(set) var cardsDealt = 12 // game initially starts with 12 cards
    private var matchSelected: Bool { isMatch(indices: selected) }
    
    init(shapes: Set<Shape>, colors: Set<Color>, numbers: Set<Number>, shadings: Set<Shading>) {
        // create deck
        cards = []
        var id = 0
        for shape in shapes {
            for color in colors {
                for number in numbers {
                    for shading in shadings {
                        let card = Card(id: id, shape: shape, color: color, number: number, shading: shading)
                        cards.append(card)
                        id += 1
                    }
                }
            }
        }
        cards.shuffle()
    }
    
    private func isMatch(indices: any Collection<Int>) -> Bool {
        return isMatch(indices.map({ cards[$0] }))
    }
    
    private func isMatch(_ cards: any Collection<Card>) -> Bool {
        return cards.count == 3
            && cards.map({ $0[keyPath: \.shape] }).allEqualOrAllUnique
            && cards.map({ $0[keyPath: \.number] }).allEqualOrAllUnique
            && cards.map({ $0[keyPath: \.color] }).allEqualOrAllUnique
            && cards.map({ $0[keyPath: \.shading] }).allEqualOrAllUnique
    }
    
    mutating func select(_ card: Card) {
        if let index = cards.index(matching: card ) {
            if selected.count >= 3 {
                // discard match
                if matchSelected {
                    selected.forEach({ cards[$0].isHidden = true })
                }
                // deselect all
                selected = []
                // if selected card was not part of previous match select it
                if !cards[index].isMatched {
                    selected.insert(index)
                }
            } else if selected.contains(index) {
                // deselect
                selected.remove(index)
            } else {
                // select and check for match
                selected.insert(index)
                if matchSelected {
                    selected.forEach({ cards[$0].isMatched = true })
                }
            }
        }
    }
    
    mutating func drawMoreCards() {
        // remove previous matches
        if matchSelected {
            selected.forEach({ cards[$0].isHidden = true })
            selected = []
        }
        if cardsDealt < cards.count {
            cardsDealt += 3
        }
    }
    
    private func findMatch() -> Set<Int>? {
        for i in 0..<cardsDealt {
            for j in 1..<cardsDealt {
                for k in 2..<cardsDealt {
                    let possibleMatch = [i, j, k]
                    if possibleMatch.allUnique, possibleMatch.allSatisfy({ cards[$0].isAvailable }), isMatch(indices: possibleMatch) {
                        return Set(possibleMatch)
                    }
                }
            }
        }
        return nil
    }
    
    mutating func cheat() -> Bool {
        // discard match
        if matchSelected {
            selected.forEach({ cards[$0].isHidden = true })
            selected = []
        }

        repeat {
            if let match = findMatch() {
                selected = match
                selected.forEach({ cards[$0].isMatched = true })
                return true
            } else {
                drawMoreCards()
            }
        } while cardsDealt < cards.count
        return false
    }
    
    struct Card: Equatable, Identifiable, Hashable {
        let id: Int
        let shape: Shape
        let color: Color
        let number: Number
        let shading: Shading
        var isMatched = false
        var isHidden = false
        var isAvailable: Bool { !isMatched && !isHidden }
        
        static func == (lhs: Card, rhs: Card) -> Bool {
            return lhs.shape == rhs.shape
                && lhs.color == rhs.color
                && lhs.number == rhs.number
                && lhs.shading == rhs.shading
        }
    }
}

extension Array where Element: Hashable {
    var allEqual: Bool {
        return self.allSatisfy({ $0 == self.first })
    }
    var allUnique: Bool {
        var seen = Set<Element>()
        return self.allSatisfy({ seen.insert($0).inserted })
    }
    var allEqualOrAllUnique: Bool {
        return self.allEqual || self.allUnique
    }
}

extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id })
    }
}
