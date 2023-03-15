//
//  UtilityExtensions.swift
//  Memorize
//
//  Created by Eng, Nick on 3/12/23.
//

import SwiftUI


// in a Collection of Identifiables
// we often might want to find the element that has the same id
// as an Identifiable we already have in hand
// we name this index(matching:) instead of firstIndex(matching:)
// because we assume that someone creating a Collection of Identifiable
// is usually going to have only one of each Identifiable thing in there
// (though there's nothing to restrict them from doing so; it's just a naming choice)

extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id })
    }
    
    func contains(matching element: Element) -> Bool {
        self.index(matching: element) != nil
    }
}

// we could do the same thing when it comes to removing an element
// but we have to add that to a different protocol
// because Collection works for immutable collections of things
// the "mutable" one is RangeReplaceableCollection
// not only could we add remove
// but we could add a subscript which takes a copy of one of the elements
// and uses its Identifiable-ness to subscript into the Collection
// this is an awesome way to create Bindings into an Array in a ViewModel
// (since any Published var in an ObservableObject can be bound to via $)
// (even vars on that Published var or subscripts on that var)
// (or subscripts on vars on that var, etc.)

extension RangeReplaceableCollection where Element: Identifiable {
    mutating func remove(_ element: Element) {
        if let index = index(matching: element) {
            remove(at: index)
        }
    }

    subscript(_ element: Element) -> Element {
        get {
            if let index = index(matching: element) {
                return self[index]
            } else {
                return element
            }
        }
        set {
            if let index = index(matching: element) {
                replaceSubrange(index...index, with: [newValue])
            }
        }
    }
}

extension Array where Element: Hashable {
    func uniqued() -> Array<Element> {
        reduce(into: []) { sofar, element in
            if !sofar.contains(element) {
                sofar.append(element)
            }
        }
    }
}

extension Character {
    var isEmoji: Bool {
        // Swift does not have a way to ask if a Character isEmoji
        // but it does let us check to see if our component scalars isEmoji
        // unfortunately unicode allows certain scalars (like 1)
        // to be modified by another scalar to become emoji (e.g. 1️⃣)
        // so the scalar "1" will report isEmoji = true
        // so we can't just check to see if the first scalar isEmoji
        // the quick and dirty here is to see if the scalar is at least the first true emoji we know of
        // (the start of the "miscellaneous items" section)
        // or check to see if this is a multiple scalar unicode sequence
        // (e.g. a 1 with a unicode modifier to force it to be presented as emoji 1️⃣)
        if let firstScalar = unicodeScalars.first, firstScalar.properties.isEmoji {
            return (firstScalar.value >= 0x238d || unicodeScalars.count > 1)
        } else {
            return false
        }
    }
}

extension Color {
     init(rgbaColor rgba: RGBAColor) {
         self.init(.sRGB, red: rgba.red, green: rgba.green, blue: rgba.blue, opacity: rgba.alpha)
     }
}
extension RGBAColor {
     init(color: Color) {
         var red: CGFloat = 0
         var green: CGFloat = 0
         var blue: CGFloat = 0
         var alpha: CGFloat = 0
         if let cgColor = color.cgColor {
             UIColor(cgColor: cgColor).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
         } else {
             UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
         }
         self.init(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
     }
}

extension Theme {
    init(id: Int, name: String, emojis: Array<String>, cards: Int, color: Color) {
        self.init(id: id, name: name, emojis: emojis, cards: cards, fill: .solid(RGBAColor(color: color)))
    }
    
    var color: Color {
        get {
            switch self.fill {
            case .solid(let color): return Color(rgbaColor: color)
            case .gradient(let top, _): return Color(rgbaColor: top)
            }
        }
        set {
            self.fill = .solid(RGBAColor(color: newValue))
        }
    }
    
    var gradient: Gradient {
        switch self.fill {
            case .solid(let color): return Gradient(colors: [Color(rgbaColor: color)])
            case .gradient(let top, let bottom): return Gradient(colors: [Color(rgbaColor: top), Color(rgbaColor: bottom)])
        }
    }
}
