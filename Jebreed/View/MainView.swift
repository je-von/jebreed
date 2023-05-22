//
//  MainView.swift
//  Jebreed
//
//  Created by Jevon Levin on 18/05/23.
//

import SwiftUI
import PhotosUI
import Charts
struct MainView: View {
    @State var uiImage: UIImage?
    @ObservedObject var classifier: ImageClassifier
    
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack{
            VStack{
                if uiImage != nil {
                    
                    Image(uiImage: uiImage!)
                        .resizable()
                        .scaledToFill()
                        .onAppear{
                            classifier.detect(uiImage: uiImage!)
                        }
                } else {
                    Image("hershey")
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(height: 340)
            .cornerRadius(12)
            .clipped()
            
            //                Button(action: {
            //                    if uiImage != nil {
            //                        classifier.detect(uiImage: uiImage!)
            //                    }
            //                }) {
            //                    Image(systemName: "bolt.fill")
            //                        .foregroundColor(.orange)
            //                        .font(.title)
            //                }
            
            if let imageClass = classifier.imageClass {
                VStack{
                    Text("Yep, that's a")
                    Text(imageClass.first?.identifier ?? "")
                        .bold()
                        .font(.title)
                    Chart(imageClass, id: \.self) { c in
                        BarMark(
                            x: .value("Source", c.confidence * 100)
                        )
                        .foregroundStyle(by: .value("Category", String(format: "\(c.identifier) (%.2f %%)", c.confidence * 100)))
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisGridLine().foregroundStyle(.clear)
                            AxisTick().foregroundStyle(.clear)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(position: .bottom) { _ in
                            AxisGridLine().foregroundStyle(.clear)
                            AxisTick().foregroundStyle(.clear)
                        }
                    }
                    .frame(height: 100)
                    
                    Text("Fun Fact: asdf")
                }
            } else {
                //                    HStack{
                //                        Text("Image categories: N/A")
                //                            .font(.caption)
                //                    }
            }
            if !classifier.isDogVisible {
                Text("Oops!")
                    .bold()
                    .font(.title)
                Text("No dog in sight, woofless!")
            }
            
            Spacer()
            
            HStack{
                Button{
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    ButtonView(text: "Retake", isPrimary: false)
                }
                if classifier.isDogVisible {
                    Button{
                        
                    } label: {
                        ButtonView(text: "Save to Collections")
                        
                    }
                }
            }
        }
//        .frame(maxHeight: .infinity)
        .padding()
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(classifier: ImageClassifier())
    }
}
