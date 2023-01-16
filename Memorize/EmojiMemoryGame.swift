//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Eng, Nick on 1/1/23.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    typealias Card = MemoryGame<String>.Card
    
    private static let themes: Array<Theme> = [
        Theme(name: "Vehicles",
              emojis: ["🚂", "🚃", "🚋", "🚌", "🚎", "🚐", "🚑", "🚒", "🚓", "🚕", "🚗", "🚙", "🛻", "🚚", "🚛", "🚜", "🏎️", "🏍️", "🛵", "🛺", "🚁", "🚲", "✈️", "🚀"],
              color: .solid(.blue)),
        Theme(name: "Christmas",
              emojis:  ["🎅", "🤶", "🦌", "🍪", "🥛", "❄️", "☃️", "🎄", "🎁", "🔔"],
              color: .solid(.green)),
        Theme(name: "Zodiac",
              emojis:  ["🐀", "🐂", "🐅", "🐇", "🐉", "🐍", "🐎", "🐑", "🐒", "🐓", "🐕", "🐖"],
              color: .solid(.red)),
        Theme(name: "Magic",
              emojis:  ["🧝", "🧚", "🪄", "🐇", "✨", "🧙", "🦄", "🔮", "🧞"],
              color: .gradient(top: .blue, bottom: .purple)),
    ]
    
    private static func createMemoryGame(theme: Theme) -> MemoryGame<String> {
        let emojis = theme.emojis.shuffled()
        return MemoryGame<String>(numberOfPairs: min(emojis.count, 8)) { pairIndex in
            emojis[pairIndex]
        }
    }
    
    private func swiftUIColor(_ color: Theme.Color) -> Color {
        switch color {
            case .purple: return .purple
            case .blue: return .blue
            case .green: return .green
            case .yellow: return .yellow
            case .orange: return .orange
            case .red: return .red
        }
    }
    
    init() {
        let theme = EmojiMemoryGame.themes.randomElement()!
        self.theme = theme
        game = EmojiMemoryGame.createMemoryGame(theme: theme)
    }
    
    @Published private var game: MemoryGame<String>
    @Published private var theme: Theme
    
    var cards: Array<Card> {
        return game.cards
    }
    
    var title: String {
        return theme.name
    }
    
    var gradientBackground: Gradient {
        switch theme.color {
            case .solid(let color): return Gradient(colors: [swiftUIColor(color)])
            case .gradient(let top, let bottom): return Gradient(colors: [swiftUIColor(top), swiftUIColor(bottom)])
        }
    }
    
    var score: Int {
        return game.score
    }
    
    // MARK: - Intents
    
    func choose(_ card: Card) {
        game.choose(card)
    }
    
    func shuffle() {
        game.shuffle()
    }
    
    func reset() {
        theme = EmojiMemoryGame.themes.randomElement()!
        game = EmojiMemoryGame.createMemoryGame(theme: theme)
    }
}
