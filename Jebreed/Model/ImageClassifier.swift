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
    
    var isDogVisible: Bool {
        classifier.isDogVisible
    }
    
    var sum: Float {
        classifier.sum
    }

    func detect(uiImage: UIImage, forceClassify: Bool = false) {
        guard let ciImage = CIImage (image: uiImage) else { return }
        classifier.detect(ciImage: ciImage, forceClassify: forceClassify)
        
    }
        
}




struct Classifier {
    
    private(set) var results: [VNClassificationObservation]?
    private(set) var isDogVisible = true
    private(set) var sum: Float = 0.0
    
//    private(set) var results: [VNRecognizedObjectObservation]?
    
    mutating func detect(ciImage: CIImage, forceClassify: Bool) {
        let defaultConfig = MLModelConfiguration()
        
        if !forceClassify{
            guard let objectDetectorModel = try? VNCoreMLModel(for: DogObjectDetector(configuration: defaultConfig).model)
            else {
                return
            }
            
            var request = VNCoreMLRequest(model: objectDetectorModel)
            
            var handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            
            try? handler.perform([request])
            
            
            
            guard let objectDetectorResults = request.results as? [VNRecognizedObjectObservation] else {
                return
            }
            
            // No dogs detected
            // TODO: show alert?
            guard !objectDetectorResults.isEmpty else {
                print("masuk sini")
                isDogVisible = false
                return
            }
            
        }
        // Object detection to detect dogs in pictures
        
        
        // Image Classification
        guard let imageClassifierModel = try? VNCoreMLModel(for: DogImageClassifier(configuration: defaultConfig).model)
        else {
            return
        }
        
        var request = VNCoreMLRequest(model: imageClassifierModel)
        
        var handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        try? handler.perform([request])
        
        
        
        guard let imageClassifierResults = request.results as? [VNClassificationObservation] else {
            return
        }
        
        self.results = Array(imageClassifierResults.prefix(upTo: 3).filter{ $0.confidence > 0.05 })
        self.sum = 0
        self.results?.forEach { r in
            self.sum += r.confidence
        }
        
        
//        self.results = imageClassifierResults.filter {$0.confidence > 0.01}
        isDogVisible = true
    }
    
}
