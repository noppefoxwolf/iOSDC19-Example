//
//  SmartViewController.swift
//  iOSDC19-Example
//
//  Created by beta on 2019/08/22.
//  Copyright © 2019 noppelab. All rights reserved.
//

import UIKit
import ARKit
import SpriteKit
import WarpGeometryFilter
import AR2DFaceDetector

class SmartViewController: UIViewController {
  let session: ARSession = .init()
  let imageView: UIImageView = .init()
  let toggle: UISwitch = .init()
  let filter: SmartFilter = .init()
  let context = CIContext()
  
  override func loadView() {
    super.loadView()
    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
    }
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: view.topAnchor),
      imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
      imageView.rightAnchor.constraint(equalTo: view.rightAnchor),
      imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    toggle.isOn = true
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
    session.run(configuration)
  }
}

extension SmartViewController: ARSessionDelegate {
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    let inputImage = CIImage(cvImageBuffer: frame.capturedImage).oriented(.right)
    let detector = AR2DFaceDetector(frame: frame, orientation: .right)
    if let perspectivePoints = detector.faces.first?.perspectivePoints, toggle.isOn {
      filter.inputImage = inputImage
      filter.perspectivePoints = perspectivePoints
      let outputImage: CIImage = filter.outputImage!
      let cgImage = context.createCGImage(outputImage, from: outputImage.extent)!
      imageView.image = UIImage(cgImage: cgImage)
    } else {
      let context = CIContext()
      let cgImage = context.createCGImage(inputImage, from: inputImage.extent)!
      imageView.image = UIImage(cgImage: cgImage)
    }
  }
}

class SmartFilter: CIFilter {
  @objc var inputImage: CIImage? = nil
  var perspectivePoints: ARPerspectivePoints2D? = nil
  private let warpGeometryFilter: WarpGeometryFilter = .init(device: MTLCreateSystemDefaultDevice()!)
  
  override var outputImage: CIImage? {
    guard let inputImage = inputImage else { return nil }
    guard let perspectivePoints = perspectivePoints else { return inputImage }
    let topLeft = perspectivePoints.topLeft.pointInImage(imageSize: inputImage.extent.size).reversedY(height: inputImage.extent.height).vector
    let topRight = perspectivePoints.topRight.pointInImage(imageSize: inputImage.extent.size).reversedY(height: inputImage.extent.height).vector
    let bottomRight = perspectivePoints.bottomRight.pointInImage(imageSize: inputImage.extent.size).reversedY(height: inputImage.extent.height).vector
    let bottomLeft = perspectivePoints.bottomLeft.pointInImage(imageSize: inputImage.extent.size).reversedY(height: inputImage.extent.height).vector
    
    let perspectiveCorrectionOutput: CIImage
    perspectiveCorrection: do {
      let filter = CIFilter(name: "CIPerspectiveCorrection")!
      filter.setValue(inputImage.clampedToExtent(), forKey: kCIInputImageKey)
      filter.setValue(topLeft, forKey: "inputTopLeft")
      filter.setValue(topRight, forKey: "inputTopRight")
      filter.setValue(bottomRight, forKey: "inputBottomRight")
      filter.setValue(bottomLeft, forKey: "inputBottomLeft")
      perspectiveCorrectionOutput = filter.outputImage!
    }
    
    let warpGeometryOutput: CIImage
    warpGeometry: do {
      let sourcePositions: [SIMD2<Float>] = [
        .init(0.00, 0.00), .init(0.10, 0.00), .init(0.90, 0.00), .init(1.00, 0.00),
        .init(0.00, 0.25), .init(0.10, 0.25), .init(0.90, 0.25), .init(1.00, 0.25),
        .init(0.00, 0.55), .init(0.10, 0.55), .init(0.90, 0.55), .init(1.00, 0.55),
        .init(0.00, 1.00), .init(0.10, 1.00), .init(0.90, 1.00), .init(1.00, 1.00),
      ]
      
      let horizontalDestinationPositions: [SIMD2<Float>] = [
        .init(0.00, 0.00), .init(0.10, 0.00), .init(0.90, 0.00), .init(1.00, 0.00),
        .init(0.00, 0.25), .init(0.13, 0.25), .init(0.87, 0.25), .init(1.00, 0.25),
        .init(0.00, 0.55), .init(0.10, 0.55), .init(0.90, 0.55), .init(1.00, 0.55),
        .init(0.00, 1.00), .init(0.10, 1.00), .init(0.90, 1.00), .init(1.00, 1.00),
      ]
      let warpGeometry = SKWarpGeometryGrid(columns: 3, rows: 3,
                                            sourcePositions: sourcePositions,
                                            destinationPositions: horizontalDestinationPositions)
      warpGeometryFilter.setValue(perspectiveCorrectionOutput, forKey: kCIInputImageKey)
      warpGeometryFilter.setValue(warpGeometry, forKey: kCIInputWarpGeometryKey)
      warpGeometryOutput = warpGeometryFilter.outputImage!
    }
    
    let perspectiveTransformOutput: CIImage
    perspectiveTransform: do {
      let filter = CIFilter(name: "CIPerspectiveTransform")!
      filter.setValue(warpGeometryOutput, forKey: kCIInputImageKey)
      filter.setValue(topLeft, forKey: "inputTopLeft")
      filter.setValue(topRight, forKey: "inputTopRight")
      filter.setValue(bottomRight, forKey: "inputBottomRight")
      filter.setValue(bottomLeft, forKey: "inputBottomLeft")
      perspectiveTransformOutput = filter.outputImage!
    }
    
    let compositedOutput: CIImage
    composited: do {
      compositedOutput = perspectiveTransformOutput.composited(over: inputImage).cropped(to: inputImage.extent)
    }
    
    return compositedOutput
  }
}
