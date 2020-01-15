//
//  NVAnimationGradientCircleRotate.swift
//  NVActivityIndicatorView-iOS
//
//  Created by Artem Sidorenko on 15.01.2020.
//  Copyright © 2020 Vinh Nguyen. All rights reserved.
//

import UIKit

class NVAnimationGradientCircleRotate: NVActivityIndicatorAnimationDelegate {
  func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
    let duration: CFTimeInterval = 1.1

    let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
    animation.keyTimes = [0, 0.2, 1]
    animation.values = [0, 0, 2 * Double.pi]
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    animation.duration = duration
    animation.repeatCount = HUGE
    animation.isRemovedOnCompletion = false
    // Draw circles
    let circle = NVActivityIndicatorShape.gradientCircle.layerWith(size: size, color: color)
    let frame = CGRect(
      x: (layer.bounds.width - size.width) / 2,
      y: (layer.bounds.height - size.height) / 2,
      width: size.width,
      height: size.height
    )
    circle.frame = frame
    circle.add(animation, forKey: "animation")
    circle.masksToBounds = true
    layer.addSublayer(circle)
  }
}
