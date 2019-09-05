//
//  VNViewController.swift
//  iOSDC19-Example
//
//  Created by beta on 2019/09/04.
//  Copyright © 2019 noppelab. All rights reserved.
//

import UIKit
import ARKit
import AR2DFaceDetector
import Vision

class VNViewController: UIViewController {
  let session: ARSession = .init()
  let imageView: UIImageView = .init()
  let ciContext = CIContext(options: nil)
    
  override func loadView() {
    super.loadView()
    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
    }
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    view.addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: view.topAnchor),
      imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
      imageView.rightAnchor.constraint(equalTo: view.rightAnchor),
      imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    session.delegate = self
    let configuration = ARFaceTrackingConfiguration()
    session.run(configuration)
  }
}

extension VNViewController: ARSessionDelegate {
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    let ciImage = CIImage(cvImageBuffer: frame.capturedImage).oriented(.rightMirrored)
    let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)!
    
    let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
    let request = VNDetectFaceLandmarksRequest { (request, error) in
        guard let observations = request.results as? [VNFaceObservation] else { return }
        UIGraphicsBeginImageContextWithOptions(ciImage.extent.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.draw(cgImage, in: ciImage.extent)
        for observation in observations {
            guard let landmarks = observation.landmarks else { return }
            context.setStrokeColor(UIColor.red.cgColor)
            context.setLineWidth(2.0)
            
            for point in landmarks.allPoints!.pointsInImage(imageSize: ciImage.extent.size) {
                context.addRect(.init(origin: point, size: .init(width: 10, height: 10)))
            }
            context.strokePath()
            
            context.setStrokeColor(UIColor.blue.cgColor)
            context.addLines(between: landmarks.faceContour!.pointsInImage(imageSize: ciImage.extent.size))
            context.addLines(between: landmarks.leftEye!.pointsInImage(imageSize: ciImage.extent.size))
            context.addLines(between: landmarks.rightEye!.pointsInImage(imageSize: ciImage.extent.size))
            context.addLines(between: landmarks.leftEyebrow!.pointsInImage(imageSize: ciImage.extent.size))
            context.addLines(between: landmarks.rightEyebrow!.pointsInImage(imageSize: ciImage.extent.size))
            context.addLines(between: landmarks.innerLips!.pointsInImage(imageSize: ciImage.extent.size))
            context.addLines(between: landmarks.outerLips!.pointsInImage(imageSize: ciImage.extent.size))
            context.addLines(between: landmarks.medianLine!.pointsInImage(imageSize: ciImage.extent.size))
            context.addLines(between: landmarks.nose!.pointsInImage(imageSize: ciImage.extent.size))
            context.addLines(between: landmarks.noseCrest!.pointsInImage(imageSize: ciImage.extent.size))
            
            context.strokePath()
        }
        let coloredImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.imageView.image = coloredImg
    }
    try! handler.perform([request])
  }
}

