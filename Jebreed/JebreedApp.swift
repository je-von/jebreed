//
//  JebreedApp.swift
//  Jebreed
//
//  Created by Jevon Levin on 18/05/23.
//

import SwiftUI

@main
struct JebreedApp: App {
//    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
//            ContentView()
//            MainView(classifier: ImageClassifier())
//            CameraView()
            SplashScreen()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}
