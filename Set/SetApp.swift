//
//  SetApp.swift
//  Set
//
//  Created by Eng, Nick on 1/14/23.
//

import SwiftUI

@main
struct SetApp: App {
    private let game = SetGameViewModel()
    var body: some Scene {
        WindowGroup {
            SetGameView(game: game)
        }
    }
}
