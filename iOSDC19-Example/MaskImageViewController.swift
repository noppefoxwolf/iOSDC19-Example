//
//  MaskImageViewController.swift
//  iOSDC19-Example
//
//  Created by beta on 2019/09/05.
//  Copyright © 2019 noppelab. All rights reserved.
//

import UIKit
import ARKit
import AR2DFaceDetector
import Vision

class MaskImageViewController: UIViewController {
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
    if #available(iOS 13.0, *) {
        configuration.frameSemantics = .personSegmentation
    }
    session.run(configuration)
  }
}

extension MaskImageViewController: ARSessionDelegate {
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    if #available(iOS 13.0, *) {
        let ciImage = CIImage(cvImageBuffer: frame.segmentationBuffer!)
        imageView.image = UIImage(ciImage: ciImage)
    }
  }
}

