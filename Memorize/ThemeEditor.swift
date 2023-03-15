//
//  ThemeEditor.swift
//  Memorize
//
//  Created by Eng, Nick on 3/13/23.
//

import SwiftUI

struct ThemeEditor: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var theme: Theme
    
    var body: some View {
        NavigationView {
            Form {
                nameSection
                removeEmojiSection
                addEmojisSection
                cardCountSection
                colorSection
            }
            .navigationTitle("Edit \(theme.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button(action: save, label: {
                        Text("Done")
                    }).disabled(!theme.isValid)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: close, label: {
                        Text("Cancel")
                    })
                }
            }
            .frame(minWidth: 300, minHeight: 350)
        }
    }
    
    var nameSection: some View {
        Section(header: Text("Theme Name")) {
            TextField("Name", text: $theme.name)
        }
    }
    
    var removeEmojiSection: some View {
        Section(header: Text("Emojis")) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(theme.emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                theme.emojis.removeAll(where: { $0 == emoji })
                            }
                        }
                }
            }
            .font(.system(size: 40))
        }
    }
    
    @State private var emojisToAdd = ""
    
    var addEmojisSection: some View {
        Section(header: Text("Add Emojis")) {
            TextField("", text: $emojisToAdd)
                .onChange(of: emojisToAdd) { emojis in
                    addEmojis(Array(emojis.filter({ $0.isEmoji }).map({ String($0) })))
                }
        }
    }
    
    func addEmojis(_ emojis: Array<String>) {
        withAnimation {
            theme.emojis = (theme.emojis + emojis).uniqued()
        }
    }
    
    var cardCountSection: some View {
        Section(header: Text("Card Count")) {
            let minCards = Theme.MinCards
            let maxCards = max(minCards, theme.emojis.count)
            Stepper("\(theme.cards) Pairs", value: $theme.cards, in: minCards...maxCards)
        }
    }
    
    private var colorSection: some View {
        Section(header: Text("Color")) {
            ColorPicker("Card Color", selection: $theme.color, supportsOpacity: false)
                .foregroundColor(theme.color)
        }
    }

    private func save() {
        theme.name = theme.name.trimmingCharacters(in: .whitespacesAndNewlines)
        close()
    }

    private func close() {
        if presentationMode.wrappedValue.isPresented {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ThemeEditor_Previews: PreviewProvider {
    static let theme = ThemeStore(named: "Preview").theme(at: 4)
    static var previews: some View {
        ThemeEditor(theme: .constant(theme))
    }
}
