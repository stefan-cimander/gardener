//
//  GardenerApp.swift
//  Gardener
//
//  Created by Stefan Cimander on 24.06.20.
//

import SwiftUI
import Firebase

@main
struct GardenerApp: App {
    
    @StateObject
    private var vocabularyStore = VocabularyStore()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            GardenerAppView(vocabularyStore: vocabularyStore)
        }
    }
}
