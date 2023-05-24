//
//  ContentView.swift
//  Jebreed
//
//  Created by Jevon Levin on 18/05/23.
//

import SwiftUI
import CoreData

struct CollectionsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        GeometryReader{ geo in
            List {
                ForEach(items) { item in
                    //                    NavigationLink {
                    HStack{
                        if item.image != nil {
                            Image(uiImage: UIImage(data: item.image!)!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .cornerRadius(12)
                                .clipped()
                        }
                        VStack (alignment: .leading){
                            Text(item.breed ?? "Breed")
                                .bold()
                                .font(.title3)
                            Text("\(item.timestamp!, formatter: itemFormatter)")
                                .font(.caption)
                        }
                        Spacer()
                        
                        Text(String(format: "%.2f%%", item.confidence * 100.0))
                    }
                    .contextMenu{
                        VStack{
                            
                            
                            Button{
                                ImageSaver().writeToPhotoAlbum(image: UIImage(data: item.image!)!)
                            } label :{
                                Label("Save to Photos", systemImage: "square.and.arrow.down")
                            }
                            
                        }
                        
                    } preview: {
                        Image(uiImage: UIImage(data: item.image!)!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width - 32)
                            .cornerRadius(12)
                            .clipped()
                    }
                    //                    } label: {
                    //                        Text(item.timestamp!, formatter: itemFormatter)
                    //                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Collections")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
