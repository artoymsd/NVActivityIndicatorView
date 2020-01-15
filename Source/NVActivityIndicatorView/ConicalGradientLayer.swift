//
//  ConicalGradientLayer.swift
//  NVActivityIndicatorView-iOS
//
//  Created by Artem Sidorenko on 15.01.2020.
//  Copyright © 2020 Vinh Nguyen. All rights reserved.
//

import UIKit

open class ConicalGradientLayer: CALayer {
  private struct Constants {
    static let maxAngle: Double = 2 * .pi
    static let maxHue = 255.0
  }
  
  private struct Transition {
    let fromLocation: Double
    let toLocation: Double
    let fromColor: UIColor
    let toColor: UIColor
    
    func color(forPercent percent: Double) -> UIColor {
      let normalizedPercent = percent.convert(fromMin: fromLocation, max: toLocation, toMin: 0.0, max: 1.0)
      return UIColor.lerp(from: fromColor.rgba, to: toColor.rgba, percent: CGFloat(normalizedPercent))
    }
  }
  
  open var colors = [UIColor]() {
    didSet {
      setNeedsDisplay()
    }
  }
  
  open var locations = [Double]() {
    didSet {
      setNeedsDisplay()
    }
  }
  
  open var startAngle: Double = 0.0 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  open var endAngle: Double = Constants.maxAngle {
    didSet {
      setNeedsDisplay()
    }
  }
  
  private var transitions = [Transition]()
  
  open override func draw(in ctx: CGContext) {
    UIGraphicsPushContext(ctx)
    draw(in: ctx.boundingBoxOfClipPath)
    UIGraphicsPopContext()
  }
  
  private func draw(in rect: CGRect) {
    loadTransitions()
    
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let longerSide = max(rect.width, rect.height)
    let radius = Double(longerSide) * 2.squareRoot()
    let step = (.pi / 2) / radius
    var angle = startAngle
    
    while angle <= endAngle {
      let pointX = radius * cos(angle) + Double(center.x)
      let pointY = radius * sin(angle) + Double(center.y)
      let startPoint = CGPoint(x: pointX, y: pointY)
      
      let line = UIBezierPath()
      line.move(to: startPoint)
      line.addLine(to: center)
      
      color(forAngle: angle).setStroke()
      line.stroke()
      
      angle += step
    }
    self.masksToBounds = true
  }
  
  private func color(forAngle angle: Double) -> UIColor {
    let percent = angle.convert(fromZeroToMax: Constants.maxAngle, toZeroToMax: 1.0)
    
    guard let transition = transition(forPercent: percent) else {
      return spectrumColor(forAngle: angle)
    }
    
    return transition.color(forPercent: percent)
  }
  
  private func spectrumColor(forAngle angle: Double) -> UIColor {
    let hue = angle.convert(fromZeroToMax: Constants.maxAngle, toZeroToMax: Constants.maxHue)
    return UIColor(hue: CGFloat(hue / Constants.maxHue), saturation: 1.0, brightness: 1.0, alpha: 1.0)
  }
  
  private func loadTransitions() {
    transitions.removeAll()
    
    if colors.count > 1 {
      let transitionsCount = colors.count - 1
      let locationStep = 1.0 / Double(transitionsCount)
      
      for i in 0 ..< transitionsCount {
        let fromLocation, toLocation: Double
        let fromColor, toColor: UIColor
        
        if locations.count == colors.count {
          fromLocation = locations[i]
          toLocation = locations[i + 1]
        } else {
          fromLocation = locationStep * Double(i)
          toLocation = locationStep * Double(i + 1)
        }
        
        fromColor = colors[i]
        toColor = colors[i + 1]
        
        let transition = Transition(fromLocation: fromLocation, toLocation: toLocation,
                                    fromColor: fromColor, toColor: toColor)
        transitions.append(transition)
      }
    }
  }
  
  private func transition(forPercent percent: Double) -> Transition? {
    let filtered = transitions.filter { percent >= $0.fromLocation && percent < $0.toLocation }
    let defaultTransition = percent <= 0.5 ? transitions.first : transitions.last
    return filtered.first ?? defaultTransition
  }
  
}

private extension Double {
  func convert(fromMin oldMin: Double, max oldMax: Double, toMin newMin: Double, max newMax: Double) -> Double {
    let oldRange, newRange, newValue: Double
    oldRange = (oldMax - oldMin)
    if (oldRange == 0.0) {
      newValue = newMin
    } else {
      newRange = (newMax - newMin)
      newValue = (((self - oldMin) * newRange) / oldRange) + newMin
    }
    return newValue
  }
  
  func convert(fromZeroToMax oldMax: Double, toZeroToMax newMax: Double) -> Double {
    return ((self * newMax) / oldMax)
  }
}

private extension UIColor {
  struct RGBA {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 0.0
    
    init(color: UIColor) {
      color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
  }
  
  var rgba: RGBA {
    return RGBA(color: self)
  }
  
  class func lerp(from: RGBA, to: RGBA, percent: CGFloat) -> UIColor {
    let red = from.red + percent * (to.red - from.red)
    let green = from.green + percent * (to.green - from.green)
    let blue = from.blue + percent * (to.blue - from.blue)
    let alpha = from.alpha + percent * (to.alpha - from.alpha)
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}
