//
//  ImageClassifier.swift
//  Jebreed
//
//  Created by Jevon Levin on 18/05/23.
//

import Foundation
import SwiftUI
import Vision
import CoreImage

class ImageClassifier: ObservableObject {
    
    @Published private var classifier = Classifier()
    
    var imageClass: [VNClassificationObservation]? {
        classifier.results
    }
        
    // MARK: Intent(s)
    func detect(uiImage: UIImage) {
        guard let ciImage = CIImage (image: uiImage) else { return }
        classifier.detect(ciImage: ciImage)
        
    }
        
}




struct Classifier {
    
    private(set) var results: [VNClassificationObservation]?
    
    mutating func detect(ciImage: CIImage) {
        let defaultConfig = MLModelConfiguration()
        guard let model = try? VNCoreMLModel(for: DogImageClassifier(configuration: defaultConfig).model)
        else {
            return
        }
        
        let request = VNCoreMLRequest(model: model)
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        try? handler.perform([request])
        
        guard let results = request.results as? [VNClassificationObservation] else {
            return
        }
        
        self.results = Array(results.prefix(upTo: 3))
        
    }
    
}
