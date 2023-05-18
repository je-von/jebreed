//
//  CameraView.swift
//  Jebreed
//
//  Created by Jevon Levin on 18/05/23.
//


import SwiftUI
import Combine
import Camera_SwiftUI
import AVFoundation
import PhotosUI
final class CameraModel: ObservableObject {
    private let service = CameraService()
    
    @Published var photo: Photo!
    
    @Published var showAlertError = false
    
    @Published var isFlashOn = false
    
    @Published var willCapturePhoto = false
    
    var alertError: AlertError!
    
    var session: AVCaptureSession
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        self.session = service.session
        
        service.$photo.sink { [weak self] (photo) in
            guard let pic = photo else { return }
            self?.photo = pic
        }
        .store(in: &self.subscriptions)
        
        service.$shouldShowAlertView.sink { [weak self] (val) in
            self?.alertError = self?.service.alertError
            self?.showAlertError = val
        }
        .store(in: &self.subscriptions)
        
        service.$flashMode.sink { [weak self] (mode) in
            self?.isFlashOn = mode == .on
        }
        .store(in: &self.subscriptions)
        
        service.$willCapturePhoto.sink { [weak self] (val) in
            self?.willCapturePhoto = val
        }
        .store(in: &self.subscriptions)
    }
    
    func configure() {
        service.checkForPermissions()
        service.configure()
    }
    
    func capturePhoto() {
        service.capturePhoto()
    }
    
    func flipCamera() {
        service.changeCamera()
    }
    
    func zoom(with factor: CGFloat) {
        service.set(zoom: factor)
    }
    
    func switchFlash() {
        service.flashMode = service.flashMode == .on ? .off : .on
    }
}

struct CameraView: View {
    @StateObject var model = CameraModel()
    
    @State var currentZoomFactor: CGFloat = 1.0
    
    @State var moveToResultPage: Bool = false
    
    @State var selectedItem: PhotosPickerItem?
    
    @State var dogImage: UIImage?
    var captureButton: some View {
        Button(action: {
            model.capturePhoto()
        }, label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 80, height: 80, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 65, height: 65, alignment: .center)
                )
        })
    }
    var openPickerButton: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Image(systemName: "photo.fill.on.rectangle.fill")
                .foregroundColor(.white)
        }
    }
    
    var flipCameraButton: some View {
        Button(action: {
            model.flipCamera()
        }, label: {
            Image(systemName: "camera.rotate.fill")
                .foregroundColor(.white)
        })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    HStack {
                        Button("Collections"){
                            
                        }
                        Spacer()
                        Button(action: {
                            model.switchFlash()
                        }, label: {
                            Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .font(.system(size: 20, weight: .medium, design: .default))
                        })
                        .accentColor(model.isFlashOn ? .yellow : .white)
                    }
                    .padding(.horizontal, 16)
                    
                    ZStack {
                        CameraPreview(session: model.session)
                            .gesture(
                                MagnificationGesture().onChanged{ scale in
                                    let zoomFactor: CGFloat = min(max(scale, 1), 5)
                                    currentZoomFactor = zoomFactor
                                    model.zoom(with: zoomFactor)
                                }
                            )
                            .onAppear {
                                model.configure()
                            }
                            .alert(isPresented: $model.showAlertError, content: {
                                Alert(title: Text(model.alertError.title), message: Text(model.alertError.message), dismissButton: .default(Text(model.alertError.primaryButtonTitle), action: {
                                    model.alertError.primaryAction?()
                                }))
                            })
                            .overlay(
                                Group {
                                    if model.willCapturePhoto {
                                        Color.black
                                    }
                                }
                        )
                        VStack{
                            Spacer()
                            Text("Position Dog in view.")
                                .foregroundColor(.white)
                                .background(.black.opacity(0.7))
                        }
                    }
                    
                    HStack {
                        openPickerButton
                        Spacer()
                        captureButton
                        Spacer()
                        flipCameraButton
                    }
                    .padding(.horizontal, 16)
                }
                
            }
            .onChange(of: model.photo){ p in
                if p != nil {
                    dogImage = model.photo != nil ? model.photo.image : nil
                    moveToResultPage = true
                }
            }
            .onChange(of: selectedItem) { newValue in
                Task {
                    if let imageData = try? await newValue?.loadTransferable(type: Data.self), let image = UIImage(data: imageData) {
                        dogImage = image
                        moveToResultPage = true
                    }
                }
            }
            .navigationDestination(isPresented: $moveToResultPage){
                MainView(uiImage: dogImage, classifier: ImageClassifier())
            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
