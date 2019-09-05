//
//  ARKitViewController.swift
//  iOSDC19-Example
//
//  Created by beta on 2019/09/04.
//  Copyright © 2019 noppelab. All rights reserved.
//

import UIKit
import ARKit
import AR2DFaceDetector
import Vision

class ARKitViewController: UIViewController {
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

extension ARKitViewController: ARSessionDelegate {
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    let ciImage = CIImage(cvImageBuffer: frame.capturedImage).oriented(.right).oriented(.downMirrored)
    let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)!
    
    if let points = AR2DFaceDetector(frame: frame, orientation: .right).faces.first?.landmarks?.allPoints?.pointsInImage(imageSize: ciImage.extent.size) {
        UIGraphicsBeginImageContextWithOptions(ciImage.extent.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.draw(cgImage, in: ciImage.extent)
        
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(2.0)
        
        for (offset, point) in points.enumerated() {
            guard offset % 2 == 0 else { continue }
            context.addRect(.init(origin: point, size: .init(width: 10, height: 10)))
        }
        
        context.strokePath()
        let coloredImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.imageView.image = coloredImg
    } else {
        imageView.image = UIImage(ciImage: ciImage.oriented(.downMirrored))
    }
    
    
  }
}

