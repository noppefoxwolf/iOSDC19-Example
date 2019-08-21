//
//  SmoothViewController.swift
//  iOSDC19-Example
//
//  Created by beta on 2019/08/22.
//  Copyright © 2019 noppelab. All rights reserved.
//

import UIKit
import ARKit
import SkinSmoothingFilter

class SmoothViewController: UIViewController {
  let session: ARSession = .init()
  let filter: SkinSmoothingFilter = .init()
  let imageView: UIImageView = .init()
  let toggle: UISwitch = .init()
  
  override func loadView() {
    super.loadView()
    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
    }
    imageView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: view.topAnchor),
      imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
      imageView.rightAnchor.constraint(equalTo: view.rightAnchor),
      imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    toggle.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(toggle)
    NSLayoutConstraint.activate([
      view.centerXAnchor.constraint(equalTo: toggle.centerXAnchor),
      view.bottomAnchor.constraint(equalTo: toggle.bottomAnchor, constant: 44)
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

extension SmoothViewController: ARSessionDelegate {
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    let capturedImage = CIImage(cvImageBuffer: frame.capturedImage)
    if #available(iOS 13.0, *) {
      if let segmentationBuffer = frame.segmentationBuffer, toggle.isOn {
        let capturedImage = CIImage(cvImageBuffer: frame.capturedImage)
        let segmentationImage = CIImage(cvImageBuffer: segmentationBuffer)
        let scale = capturedImage.extent.width / segmentationImage.extent.width
        filter.setValue(capturedImage, forKey: kCIInputImageKey)
        filter.setValue(segmentationImage.transformed(by: .init(scaleX: scale, y: scale)), forKey: kCIInputMaskImageKey)
        imageView.image = UIImage(ciImage: filter.outputImage!.oriented(.right))
      } else {
        imageView.image = UIImage(ciImage: capturedImage.oriented(.right))
      }
    }
  }
}
