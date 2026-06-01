//
//  EnterGameWaitingView.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/12/24.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class EnterGameWaitingView: UIView {

    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.35)
        alpha = 0.0
        transform = .identity
        
        let containView = UIView().addTo(superView: self).configure { (containView) in
            containView.backgroundColor = R.color.appColor._fae7ca()
            }.layout { (make) in
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalTo(100)
                make.center.equalToSuperview()
        }
        
        let waitingImageView = UIImageView().addTo(superView: containView).configure { (imageView) in
            imageView.image = R.image.loading_1()
            imageView.animationImages = [R.image.loading_1()!, R.image.loading_2()!, R.image.loading_3()!, R.image.loading_4()!]
            imageView.animationDuration = 0.6
            imageView.startAnimating()
            }.layout { (make) in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(20)
        }
        
        UILabel().addTo(superView: containView).configure { (label) in
            label.font = UIFont.size14
            label.textColor = R.color.appColor._666666()
            label.textAlignment = .center
            label.text = "Loading....."
            }.layout { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(waitingImageView.snp.bottom).offset(15)
        }
        containView.layoutIfNeeded()
    }
    
    class func waitingView(from: UIView) -> EnterGameWaitingView? {
        for subView in from.subviews.reversed() {
            if subView.isKind(of: EnterGameWaitingView.self) {
                return subView as? EnterGameWaitingView
            }
        }
        return nil
    }
    
    func show(inView: UIView) {
        inView.addSubview(self)
        transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
    
    func dismiss(animate: Bool) {
        guard animate else {
            removeFromSuperview()
            return
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
            self.alpha = 0.0
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
