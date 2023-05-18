//
//  Classifier.swift
//  Jebreed
//
//  Created by Jevon Levin on 18/05/23.
//

import Foundation

import Vision
import CoreImage

struct Classifier {
    
    private(set) var results: String?
    
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
        
        if let firstResult = results.first {
            self.results = firstResult.identifier
        }
        
    }
    
}
