//
//  Transition.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/8.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class TransitionController: NSObject, UIViewControllerTransitioningDelegate {

    private let presentAnimation = PresentAnimation()
    private let dismissAnimation = DismissAnimation()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimation
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimation
    }
}
