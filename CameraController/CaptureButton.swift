//
//  CaptureButton.swift
//  CameraController
//
//  Created by Артём Зайцев on 18.03.2020.
//  Copyright © 2020 Артём Зайцев. All rights reserved.
//

import UIKit


class CaptureButton: UIButton {
    static let buttonRadius: CGFloat = 32.0
    
    var buttonLayer: CALayer = {
        let l = CALayer()
        l.backgroundColor = UIColor.white.cgColor
        l.cornerRadius = CaptureButton.buttonRadius
        return l
    }()
    var borderLayer: CALayer = {
        let l = CALayer()
        l.borderColor = UIColor.white.cgColor
        l.borderWidth = 4.0
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalToConstant: CaptureButton.buttonRadius * 2).isActive = true
        widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0).isActive = true
        
        layer.insertSublayer(buttonLayer, at: 0)
        layer.insertSublayer(borderLayer, at: 1)
        
        let b = CGRect(x: 0.0, y: 0.0, width: CaptureButton.buttonRadius * 2.0, height: CaptureButton.buttonRadius * 2.0)
        buttonLayer.frame = b
        borderLayer.cornerRadius = CaptureButton.buttonRadius + 8.0
        borderLayer.frame = b.inset(by: UIEdgeInsets(top: -8.0, left: -8.0, bottom: -8.0, right: -8.0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func animateStartCapture() {
        let inset: CGFloat = 16.0
        let newBounds = buttonLayer.bounds.inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))

        buttonLayer.cornerRadius = 4.0
        buttonLayer.bounds = newBounds
        buttonLayer.backgroundColor = UIColor.red.cgColor
    }
    
    public func animateStopCapture() {
        buttonLayer.cornerRadius = bounds.height / 2.0
        buttonLayer.bounds = bounds
        buttonLayer.backgroundColor = UIColor.white.cgColor
    }
}
