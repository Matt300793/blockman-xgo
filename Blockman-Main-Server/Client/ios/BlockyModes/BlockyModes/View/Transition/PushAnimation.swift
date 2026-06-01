//
//  PushAnimation.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/26.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class PushAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    private var operation: UINavigationControllerOperation
    private(set) weak var fromViewController: BaseViewController?
    private weak var toViewController: BaseViewController?
    
    init(navigation operation: UINavigationControllerOperation, from fromVC: BaseViewController, to toVC: BaseViewController) {
        self.operation = operation
        fromViewController = fromVC
        toViewController = toVC
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.45
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewController(forKey: .from) as! BaseViewController
        let toVC = transitionContext.viewController(forKey: .to) as! BaseViewController
        let duration = transitionDuration(using: transitionContext)
        
        if operation == .push {
            transitionContext.containerView.addSubview(fromVC.snapshot ?? fromVC.view)
            fromVC.view.isHidden = true
            
            let finalFrame = transitionContext.finalFrame(for: toVC)
            toVC.view.frame = finalFrame.offsetBy(dx: finalFrame.size.width, dy: 0)
            transitionContext.containerView.addSubview(toVC.view)
            
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                fromVC.snapshot?.alpha = 0
                fromVC.snapshot?.frame = fromVC.view.frame.insetBy(dx: 20, dy: 20)
                toVC.view.frame = finalFrame
            }) { (finished) in
                fromVC.view.isHidden = false
                fromVC.snapshot?.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }else if operation == .pop {
            
            fromVC.view.addSubview(fromVC.snapshot ?? fromVC.view)
            fromVC.snapshot?.y -= 64
            let tabBarHidden = fromVC.tabBarController?.tabBar.isHidden ?? true
            
            fromVC.navigationController?.navigationBar.isHidden = true
            fromVC.tabBarController?.tabBar.isHidden = true
            
            toVC.snapshot?.alpha = 0.5
            toVC.snapshot?.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
            
            let toViewWrapperView = UIView(frame: transitionContext.containerView.bounds)
            toViewWrapperView.addSubview(toVC.view)
            toViewWrapperView.isHidden = true
         
            transitionContext.containerView.addSubview(toViewWrapperView)
            transitionContext.containerView.addSubview(toVC.snapshot ?? toVC.view)
            transitionContext.containerView.bringSubview(toFront: fromVC.view)
            
            UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
                fromVC.view.frame = fromVC.view.frame.offsetBy(dx: fromVC.view.width, dy: 0)
                toVC.snapshot?.alpha = 1
                toVC.snapshot?.transform = CGAffineTransform.identity
            }, completion: { (finished) in
                
                toVC.navigationController?.navigationBar.isHidden = false;
                toVC.tabBarController?.tabBar.isHidden = tabBarHidden
                
                fromVC.snapshot?.removeFromSuperview()
                toVC.snapshot?.removeFromSuperview()
                
                
                if !transitionContext.transitionWasCancelled {
                    for subView in toViewWrapperView.subviews {
                        transitionContext.containerView.addSubview(subView)
                    }
                }
                toViewWrapperView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
//            let toViewWrapperView = UIView(frame: transitionContext.containerView.bounds)
//            toViewWrapperView.addSubview(toVC.view)
//            toViewWrapperView.isHidden = true
//
//            transitionContext.containerView.addSubview(toViewWrapperView)
        }
    }

}
