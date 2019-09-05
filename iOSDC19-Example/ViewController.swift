//
//  ViewController.swift
//  iOSDC19-Example
//
//  Created by beta on 2019/08/21.
//  Copyright © 2019 noppelab. All rights reserved.
//

import UIKit
import AR2DFaceDetector
import SkinSmoothingFilter
import WarpGeometryFilter

class ViewController: UIViewController {
  
  enum Scene: Int, CaseIterable {
    case sticker
    case smooth
    case smart
    case cidetector
    case vision
    case arkit
    case semantics
  }
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.delegate = self
      tableView.dataSource = self
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
  }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Scene.allCases.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = "\(Scene(rawValue: indexPath.row)!)"
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch Scene(rawValue: indexPath.row) {
    case .some(.sticker):
        let vc = StickerViewController()
        present(vc, animated: true, completion: nil)
    case .some(.smooth):
        let vc = SmoothViewController()
        present(vc, animated: true, completion: nil)
    case .smart:
        let vc = SmartViewController()
        present(vc, animated: true, completion: nil)
    case .cidetector:
        let vc = CIDetectorViewController()
        present(vc, animated: true, completion: nil)
    case .vision:
        let vc = VNViewController()
        present(vc, animated: true, completion: nil)
    case .arkit:
        let vc = ARKitViewController()
        present(vc, animated: true, completion: nil)
    case .semantics:
        let vc = MaskImageViewController()
        present(vc, animated: true, completion: nil)
    default: break
    }
  }
}


