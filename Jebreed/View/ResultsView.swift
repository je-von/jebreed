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
struct ResultsView: View {
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
        GeometryReader { geo in
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
                .padding(.bottom)
                .contextMenu{
                    VStack{
                        Button{
                            ImageSaver().writeToPhotoAlbum(image: uiImage!)
                        } label :{
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                        }
                    }
                    
                } preview: {
                    Image(uiImage: uiImage!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width - 32)
                        .cornerRadius(12)
                        .clipped()
                }
                
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
                            .clipShape(RoundedCorner(radius: 12, corners: imageClass.count == 1 ? [.allCorners] : c == imageClass.first ? [.bottomLeft, .topLeft] : c == imageClass.last ? [.bottomRight, .topRight] : []))
                            .foregroundStyle(by: .value("Category", String(format: "\(c.identifier) (%.2f %%)                                                        ", c.confidence * 100)))
                            
                        }
                        .chartXScale(domain: 0...(classifier.sum * 100))
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
                        .frame(height: 20 * CGFloat(imageClass.count + 1) + 20)
                        .padding(.bottom)
                        Text(Image(systemName: "info.circle"))
                        +
                        Text(" Fun Fact: \(funFacts[classifier.imageClass?.first?.identifier ?? "default"] ?? "")")
                    }
                } else {
                }
                if !classifier.isDogVisible {
                    Text("Oops!")
                        .bold()
                        .font(.title)
                    Text("No dog in sight, woofless!")
                }
                Spacer()
                
                if !classifier.isDogVisible {
                    Text(Image(systemName: "info.circle"))
                    +
                    Text(" Second-guessing our move? Click the button below if you're certain there's a dog there!")
                    Button{
                        withAnimation{
                            classifier.detect(uiImage: uiImage!, forceClassify: true)
                        }
                    } label: {
                        ButtonView(text: "Indeed, there's definitely a doggo!")
                        
                    }
                } else {
                    HStack{
                        Button{
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            ButtonView(text: "Retake", isPrimary: false)
                        }
                        //                if classifier.isDogVisible {
                        //                    if hasSaved {
                        //                        NavigationLink{
                        //                            ContentView()
                        //                                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        //                        } label: {
                        //                            ButtonView(text: "View Collections")
                        //                        }
                        //                    } else {
                        Button{
                            addItem()
                        } label: {
                            ButtonView(text: !hasSaved ? "Save to Collections" : "Saved!", disabled: hasSaved)
                            
                        }
                        .disabled(hasSaved)
                        //                    }
                        //                }
                    }
                    
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Collections"){
                        CollectionsView()
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    }
                }
            }
            //        .frame(maxHeight: .infinity)
        .padding()
        }
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
        ResultsView(classifier: ImageClassifier())
    }
}


struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

