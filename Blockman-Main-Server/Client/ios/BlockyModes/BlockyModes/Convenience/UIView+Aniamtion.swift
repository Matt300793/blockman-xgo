//
//  UIView+Aniamtion.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/26.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

protocol BMAnimation {
    func beatingAnimation()
}

extension BMAnimation where Self: UIView {
    func beatingAnimation() {
        self.layer.removeAnimation(forKey: "beatingAnimation")
        
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.duration = 0.5
        animation.values = [0.3, 1.1, 0.8, 1.0]
        self.layer.add(animation, forKey: "beatingAnimation")
    }
}

extension UIView: BMAnimation { }
