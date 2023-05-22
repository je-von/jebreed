//
//  SplashScreen.swift
//  Jebreed
//
//  Created by Jevon Levin on 22/05/23.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack{
            GeometryReader { geo in
                Image("hershey")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: geo.size.width - 80, height: geo.size.height, alignment: .center)
                
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                VStack (spacing: 15){
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
                    
                    Button{
                        
                    } label: {
                        Text("Start")
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(.primary)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
