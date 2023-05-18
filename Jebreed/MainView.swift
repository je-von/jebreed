//
//  MainView.swift
//  Jebreed
//
//  Created by Jevon Levin on 18/05/23.
//

import SwiftUI
import PhotosUI
struct MainView: View {
    @State var uiImage: UIImage?
    @ObservedObject var classifier: ImageClassifier
    var body: some View {
        VStack{
            Rectangle()
                .strokeBorder()
                .foregroundColor(.yellow)
                .overlay(
                    Group {
                        if uiImage != nil {
                            Image(uiImage: uiImage!)
                                .resizable()
                                .scaledToFit()
                                .onAppear{
                                    classifier.detect(uiImage: uiImage!)
                                }
                        }
                    }
                )
            
            
            VStack{
//                Button(action: {
//                    if uiImage != nil {
//                        classifier.detect(uiImage: uiImage!)
//                    }
//                }) {
//                    Image(systemName: "bolt.fill")
//                        .foregroundColor(.orange)
//                        .font(.title)
//                }
                
                
                Group {
                    if let imageClass = classifier.imageClass {
                        HStack{
                            Text("Image categories:")
                                .font(.caption)
                            ForEach(imageClass, id: \.self){ c in
                                Text("\(c.identifier) (\(Int(ceil(c.confidence * 100)))%) ")
                                    .bold()
                            }
                        }
                    } else {
                        HStack{
                            Text("Image categories: N/A")
                                .font(.caption)
                        }
                    }
                }
                .font(.subheadline)
                .padding()
                
            }
        }
        
        .padding()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(classifier: ImageClassifier())
    }
}
