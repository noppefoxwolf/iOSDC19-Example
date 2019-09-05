//
//  StickerViewController.swift
//  iOSDC19-Example
//
//  Created by beta on 2019/08/21.
//  Copyright © 2019 noppelab. All rights reserved.
//

import UIKit
import ARKit
import AR2DFaceDetector

class CIDetectorViewController: UIViewController {
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

extension CIDetectorViewController: ARSessionDelegate {
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    let ciImage = CIImage(cvImageBuffer: frame.capturedImage).oriented(.rightMirrored)
    let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)!
    
    let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: nil)!
    let features = detector.features(in: ciImage)
    UIGraphicsBeginImageContextWithOptions(ciImage.extent.size, false, 1)
    let context = UIGraphicsGetCurrentContext()!
    context.draw(cgImage, in: ciImage.extent)
    for feature in features {
        guard let feature = feature as? CIFaceFeature else { return }
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(2.0)
        context.addRect(feature.bounds)
        context.addRect(.init(origin: feature.leftEyePosition, size: .init(width: 10, height: 10)))
        context.addRect(.init(origin: feature.rightEyePosition, size: .init(width: 10, height: 10)))
        context.addRect(.init(origin: feature.mouthPosition, size: .init(width: 10, height: 10)))
        context.strokePath()
    }
    let coloredImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    imageView.image = coloredImg
  }
}
