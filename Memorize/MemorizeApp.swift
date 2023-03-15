//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Eng, Nick on 12/7/22.
//

import SwiftUI

@main
struct MemorizeApp: App {
    @StateObject var themeStore = ThemeStore(named: "Default")
    var body: some Scene {
        WindowGroup {
            ThemeChooser(store: .constant(themeStore))
        }
    }
}
