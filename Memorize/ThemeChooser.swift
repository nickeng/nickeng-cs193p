//
//  ThemeChooser.swift
//  Memorize
//
//  Created by Eng, Nick on 3/12/23.
//

import SwiftUI

struct ThemeChooser: View {
    @Binding var store: ThemeStore
    
    @State var games = Dictionary<Int,EmojiMemoryGame>()
    
    // a Binding to a PresentationMode
    // which lets us dismiss() ourselves if we are isPresented
    @Environment(\.presentationMode) var presentationMode
    
    // we inject a Binding to this in the environment for the List and EditButton
    // using the \.editMode in EnvironmentValues
    @State private var editMode: EditMode = .inactive
    @State private var themeToEdit: Theme?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.themes) { theme in
                    // tapping on this row in the List will navigate to a PaletteEditor
                    // (not subscripting by the Identifiable)
                    // (see the subscript added to RangeReplaceableCollection in UtilityExtensiosn)
                    NavigationLink(destination: EmojiMemoryGameView(game: games[theme.id, default: EmojiMemoryGame(theme: theme)])) {
                        VStack(alignment: .leading) {
                            Text(theme.name)
                                .foregroundColor(theme.color)
                                .font(.title2)
                            Text(theme.emojis.joined(separator: " "))
                        }
                        // tapping when NOT in editMode will follow the NavigationLink
                        // (that's why gesture is set to nil in that case)
                        .gesture(editMode == .active ? tapToEdit(theme: theme) : nil)
                    }
                }
                // teach the ForEach how to delete items
                // at the indices in indexSet from its array
                .onDelete { indexSet in
                    store.themes.remove(atOffsets: indexSet)
                }
                // teach the ForEach how to move items
                // at the indices in indexSet to a newOffset in its array
                .onMove { indexSet, newOffset in
                    store.themes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationTitle("Memorize")
            // add an EditButton on the trailing side of our NavigationView
            // and a Close button on the leading side
            // notice we are adding this .toolbar to the List
            // (not to the NavigationView)
            // (NavigationView looks at the View it is currently showing for toolbar info)
            // (ditto title and titledisplaymode above)
            .toolbar {
                ToolbarItem { EditButton() }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        themeToEdit = store.insertTheme(name: "New Theme")
                    } label: {
                        Image(systemName: "plus").imageScale(.large)
                    }
                }
            }
            // see comment for editMode @State above
            .environment(\.editMode, $editMode)
        }
        .sheet(item: $themeToEdit, onDismiss: removeInvalidThemes) { theme in
            ThemeEditor(theme: $store.themes[theme])
        }
        .onChange(of: store.themes) { themes in
            games.forEach { (id, game) in
                // update changed themes
                if (game.theme != themes[game.theme]) {
                    game.theme = themes[game.theme]
                }
            }
        }
    }
    
    private func tapToEdit(theme: Theme) -> some Gesture {
        TapGesture().onEnded {
            themeToEdit = theme
        }
    }
    
    private func removeInvalidThemes() {
        store.themes = store.themes.filter({ $0.isValid })
    }
}

struct ThemeChooser_Previews: PreviewProvider {
    static let themeStore = ThemeStore(named: "Previews")
    static var previews: some View {
        ThemeChooser(store: .constant(themeStore)).preferredColorScheme(.light)
        ThemeChooser(store: .constant(themeStore)).preferredColorScheme(.dark)
    }
}
