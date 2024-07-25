//
//  UIView+Extensions.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 24/7/24.
//

import UIKit

extension UIView {
    func shake() {
        // Animación de sacudida
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.05
        shakeAnimation.repeatCount = 4
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 5, y: self.center.y))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 5, y: self.center.y))
        
        // Animación de rotación
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = -0.07 // Rota a la izquierda
        rotationAnimation.toValue = 0.07   // Rota a la derecha
        rotationAnimation.duration = 0.05
        rotationAnimation.repeatCount = 4
        rotationAnimation.autoreverses = true
        
        // Añadir ambas animaciones
        self.layer.add(shakeAnimation, forKey: "position")
        self.layer.add(rotationAnimation, forKey: "rotation")
    }
}

extension UIView {
  func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
      let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                              cornerRadii: CGSize(width: radius, height: radius))
      let mask = CAShapeLayer()
      mask.path = path.cgPath
      layer.mask = mask
  }
}
