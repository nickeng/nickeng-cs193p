//
//  ThemeStore.swift
//  Memorize
//
//  Created by Eng, Nick on 3/12/23.
//

import Foundation

class ThemeStore: ObservableObject {
    let name: String
    
    @Published var themes = [Theme]() {
        didSet {
            storeInUserDefaults()
        }
    }
    
    private var userDefaultsKey: String {
        "ThemeStore:" + name
    }
    
    private func storeInUserDefaults() {
        UserDefaults.standard.set(try? JSONEncoder().encode(themes), forKey: userDefaultsKey)
    }
    
    private func restoreFromUserDefaults() {
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedThemes = try? JSONDecoder().decode(Array<Theme>.self, from: jsonData) {
            themes = decodedThemes
        }
    }
    
    init(named name: String) {
        self.name = name
        restoreFromUserDefaults()
        if themes.isEmpty {
            insertTheme(name: "Vehicles",
                        emojis: ["🚂", "🚃", "🚋", "🚌", "🚎", "🚐", "🚑", "🚒", "🚓", "🚕", "🚗", "🚙", "🛻", "🚚", "🚛", "🚜", "🏎️", "🏍️", "🛵", "🛺", "🚁", "🚲", "✈️", "🚀"],
                        cards: 8,
                        color: .solid(RGBAColor(color: .blue)))
            insertTheme(name: "Christmas",
                        emojis:  ["🎅", "🤶", "🦌", "🍪", "🥛", "❄️", "☃️", "🎄", "🎁", "🔔"],
                        cards: 8,
                        color: .solid(RGBAColor(color: .green)))
            insertTheme(name: "Zodiac",
                        emojis:  ["🐀", "🐂", "🐅", "🐇", "🐉", "🐍", "🐎", "🐑", "🐒", "🐓", "🐕", "🐖"],
                        cards: 8,
                        color: .solid(RGBAColor(color: .red)))
            insertTheme(name: "Magic",
                        emojis:  ["🧝", "🧚", "🪄", "🐇", "✨", "🧙", "🦄", "🔮", "🧞"],
                        cards: 8,
                        color: .gradient(top: RGBAColor(color: .blue), bottom: RGBAColor(color: .purple)))
        }
    }
    
    // MARK: - Intent
    
    func theme(at index: Int) -> Theme {
        let safeIndex = min(max(index, 0), themes.count - 1)
        return themes[safeIndex]
    }
    
    @discardableResult
    func removeTheme(at index: Int) -> Int {
        if themes.count > 1, themes.indices.contains(index) {
            themes.remove(at: index)
        }
        return index % themes.count
    }
    
    func insertTheme(name: String, emojis: Array<String>? = nil, cards: Int? = nil, color: Theme.Fill? = nil, at index: Int = 0) -> Theme {
        let unique = (themes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let theme = Theme(id: unique, name: name, emojis: emojis ?? [], cards: cards ?? Theme.MinCards, fill: color ?? .solid(RGBAColor(color: .blue)))
        let safeIndex = min(max(index, 0), themes.count)
        themes.insert(theme, at: safeIndex)
        return theme
    }
}
