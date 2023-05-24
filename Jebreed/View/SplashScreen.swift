//
//  SplashScreen.swift
//  Jebreed
//
//  Created by Jevon Levin on 22/05/23.
//

import SwiftUI

struct SplashScreen: View {
    let persistenceController = PersistenceController.shared
    var body: some View {
        NavigationStack {
            ZStack{
                GeometryReader { geo in
                    Image("hershey")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: geo.size.width - 80, height: geo.size.height, alignment: .center)
                    
                    Color.black.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)
                    VStack (spacing: 20){
                        Text("Jebreed")
                            .foregroundColor(.white)
                            .bold()
                            .font(.system(size: 48))
                        Spacer()
                        Text("Welcome!")
                            .foregroundColor(.white)
                            .font(.title)
                            .bold()
                        Text("Grant camera access and let our app work its magic to identify dog breeds around you!")
                            .foregroundColor(.white)
                        NavigationLink{
                            CameraView()
                        } label: {
                            //                            Text("asd")
                            ButtonView(text: "Start Capturing")
                        }
                        NavigationLink{
                            ContentView()
                                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        } label: {
                            //                            Text("asd")
                            ButtonView(text: "View My Collections", isPrimary: false)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
