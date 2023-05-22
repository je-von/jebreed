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
    var body: some View {
        ScrollView{
            VStack{
                VStack{
                    if uiImage != nil {
                        
                        Image(uiImage: uiImage!)
                            .resizable()
                            .scaledToFill()
                            .onAppear{
                                classifier.detect(uiImage: uiImage!)
                            }
                    }
                }
                .frame(width: 300, height: 300)
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
                        Text("Image categories:")
                            .font(.caption)
                        Chart(imageClass, id: \.self) { c in
                            BarMark(
                                x: .value("Source", c.confidence * 100)
                            )
                            .foregroundStyle(by: .value("Category", String(format: "\(c.identifier) (%.2f %%)", c.confidence * 100)))
                            //                                .annotation(position: .overlay) {
                            //                                    Text(course.students.formatted())
                            //                                        .font(.caption.bold())
                            //                                }
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
                        .frame(height: 50)
                        .border(.white)
                        
                        //                            ForEach(imageClass, id: \.self){ c in
                        ////                                Text("\(c.description) (\(Int(ceil(c.confidence * 100)))%) ")
                        //                                Text(String(format: "\(c.identifier) (%.2f %%)", c.confidence * 100))
                        //                                    .bold()
                        //                            }
                        
                        
                    }
                } else {
                    HStack{
                        Text("Image categories: N/A")
                            .font(.caption)
                    }
                }
                if !classifier.isDogVisible {
                    Text("DOG NOT FOUND!!!")
                }
                
                Spacer()
                
                Button("Test"){
                    
                }
            }
            
            
            
            
            
            .padding()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(classifier: ImageClassifier())
    }
}
