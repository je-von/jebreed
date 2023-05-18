//
//  JebreedApp.swift
//  Jebreed
//
//  Created by Jevon Levin on 18/05/23.
//

import SwiftUI

@main
struct JebreedApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            MainView(classifier: ImageClassifier())
        }
    }
}
