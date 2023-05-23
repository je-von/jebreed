//
//  MainView.swift
//  Jebreed
//
//  Created by Jevon Levin on 18/05/23.
//

import SwiftUI
import PhotosUI
import Charts
import CoreData
struct MainView: View {
    @State var uiImage: UIImage?
    @ObservedObject var classifier: ImageClassifier
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var hasSaved = false
    
    let persistenceController = PersistenceController.shared
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
            
            
            if let imageClass = classifier.imageClass {
                VStack{
                    Text("Yep, that's a")
                    Text(imageClass.first?.identifier ?? "")
                        .bold()
                        .font(.title)
                    GeometryReader{ geo in
                        VStack{
                            Text("geo: \(geo.size.height)")
                            
                            Chart(imageClass, id: \.self) { c in
                                BarMark(
                                    x: .value("Source", c.confidence * 100)
                                )
                                .foregroundStyle(by: .value("Category", String(format: "\(c.identifier) (%.2f %%)", c.confidence * 100)))
                                
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
                        }
                    }
                    
                    Text("Fun Fact: \(funFacts[classifier.imageClass?.first?.identifier ?? "default"] ?? "")")
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
                    if hasSaved {
                        NavigationLink{
                            ContentView()
                                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        } label: {
                            ButtonView(text: "View Collections")
                        }
                    } else {
                        Button{
                            addItem()
                        } label: {
                            ButtonView(text: "Save to Collections")
                            
                        }
                    }
                }
            }
        }
        //        .frame(maxHeight: .infinity)
        .padding()
    }
    
    private func addItem() {
        //        withAnimation {
        let newItem = Item(context: viewContext)
        
        let pngImageData  = uiImage?.pngData()
        newItem.image = pngImageData
        newItem.timestamp = Date()
        newItem.breed = classifier.imageClass?.first?.identifier ?? ""
        newItem.confidence = Double(classifier.imageClass?.first?.confidence ?? 0 * 100.0)
        do {
            try viewContext.save()
            
            withAnimation{
                hasSaved = true
            }
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        //        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(classifier: ImageClassifier())
    }
}
