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

class StickerViewController: UIViewController {
  let session: ARSession = .init()
  let imageView: UIImageView = .init()
  
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
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    session.delegate = self
    let configuration = ARFaceTrackingConfiguration()
    session.run(configuration)
  }
}

extension StickerViewController: ARSessionDelegate {
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    let capturedImage = CIImage(cvImageBuffer: frame.capturedImage)
    let nose = AR2DFaceDetector(frame: frame).faces.first?.landmarks?.nose
    let filter = StickerFilter()
    filter.inputImage = capturedImage
    filter.inputStickerImage = CIImage(image: UIImage(named: "Sticker")!)!.oriented(.left)
    filter.faceLandmarkRegion = nose
    imageView.image = UIImage(ciImage: filter.outputImage!.oriented(.right))
  }
}


let kCIInputFaceLandmarkRegionCenterKey: String = "faceLandmarkRegion"

class StickerFilter: CIFilter {
  @objc var inputImage: CIImage? = nil
  @objc var inputStickerImage: CIImage? = nil
  var faceLandmarkRegion: ARFaceLandmarkRegion2D? = nil
  
  override var outputImage: CIImage? {
    guard let inputImage = inputImage else { return self.inputImage }
    guard let inputStickerImage = inputStickerImage else { return inputImage }
    guard let faceLandmarkRegion = faceLandmarkRegion else { return inputImage }
    let translateMatrix = faceLandmarkRegion.pointsInImage(imageSize: inputImage.extent.size)[0].simd - inputImage.extent.size.center.simd
    let transform: CGAffineTransform = CGAffineTransform(translationX: CGFloat(translateMatrix.x), y: -CGFloat(translateMatrix.y)).translatedBy(x: 200/2, y: 300/2)
    let transformedStickerImage = inputStickerImage.transformed(by: transform)
    return transformedStickerImage.composited(over: inputImage).cropped(to: inputImage.extent)
  }
}
