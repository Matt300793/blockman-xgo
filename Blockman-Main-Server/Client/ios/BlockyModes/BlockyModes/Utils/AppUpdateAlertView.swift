//
//  AppUpdateAlertView.swift
//  BlockyModes
//
//  Created by KiBen on 2017/12/27.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class AppUpdateAlertView: UIView {
    
    private let disposeBag = DisposeBag()
    private weak var containView: UIView?
    
    required init(updateContent: String, downloadURLString: String, thumbnailURLString: String? = nil, forceUpdate: Bool = false) {
        super.init(frame: .zero)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.35)
        
        let containView = UIView().addTo(superView: self).configure { (containView) in
            containView.backgroundColor = R.color.appColor._fae7ca()
            }.layout { (make) in
                make.width.equalTo(270)
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(-UIScreen.main.bounds.size.height * 0.45)
        }
        self.containView = containView
        
        let thumbnailView = NetImageView().addTo(superView: containView).configure { (imageView) in
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            }.layout { (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(thumbnailURLString != nil ? 100 : 0)
        }
        thumbnailView.imageWithUrlString(thumbnailURLString)
        
        let updateTitleLabel = UILabel().addTo(superView: containView).configure { (label) in
            label.font = UIFont.size15
            label.textColor = R.color.appColor._333333()
            label.text = "更新内容"
            }.layout { (make) in
                make.left.equalToSuperview().offset(24)
                make.top.equalTo(thumbnailView.snp.bottom).offset(19)
        }
        
        let contentLabel = UILabel().addTo(superView: containView).configure { (label) in
            label.numberOfLines = 0
            label.font = UIFont.size12
            label.textColor = R.color.appColor._666666()
            label.text = updateContent
            }.layout { (make) in
                make.left.equalToSuperview().offset(24)
                make.top.equalTo(updateTitleLabel.snp.bottom).offset(19)
        }
        
        let horizontalLine = UIView().addTo(superView: containView).configure { (line) in
            line.backgroundColor = R.color.appColor._e7c99e()
            }.layout { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(contentLabel.snp.bottom).offset(20)
                make.height.equalTo(1)
        }
        
        let verticalLine = UIView().addTo(superView: containView).configure { (line) in
            line.backgroundColor = R.color.appColor._e7c99e()
            }.layout { (make) in
                make.top.equalTo(horizontalLine.snp.bottom)
                make.size.equalTo(CGSize(width: 1, height: 50))
                make.centerX.equalToSuperview()
        }
        
        let cancelButton = UIButton().addTo(superView: containView).configure { (button) in
            button.setTitle("取消", for: .normal)
            button.titleLabel?.font = UIFont.boldSize18
            button.setTitleColor(R.color.appColor._333333(), for: .normal)
            }.layout { (make) in
                make.left.equalToSuperview()
                make.top.equalTo(horizontalLine.snp.bottom)
                make.right.equalTo(verticalLine.snp.left)
                make.height.equalTo(verticalLine.snp.height)
        }
        cancelButton.rx.tap.subscribe(onNext: {[weak self] in
            AnalysisManager.trackEvent(AnalysisManager.Event.home_cancel)
            self?.removeFromSuperview()
        }).disposed(by: disposeBag)
        
        if forceUpdate {
            verticalLine.isHidden = true
            cancelButton.isHidden = true
        }
        
        let updateButton = UIButton().addTo(superView: containView).configure { (button) in
            button.setTitle("更新", for: .normal)
            button.titleLabel?.font = UIFont.boldSize18
            button.setTitleColor(R.color.appColor._0ab950(), for: .normal)
            }.layout { (make) in
                make.right.equalToSuperview()
                make.top.equalTo(horizontalLine.snp.bottom)
                let _ = forceUpdate ? make.left.equalToSuperview() : make.left.equalTo(verticalLine.snp.right)
                make.height.equalTo(cancelButton.snp.height)
        }
        updateButton.rx.tap.subscribe(onNext: {[weak self] in
            self?.removeFromSuperview()
            AnalysisManager.trackEvent(AnalysisManager.Event.home_update)
            let downloadURL = URL.init(string: downloadURLString)!
            if UIApplication.shared.canOpenURL(downloadURL) {
                UIApplication.shared.openURL(downloadURL)
            }
        }).disposed(by: disposeBag)
        
        containView.snp.makeConstraints { (make) in
            make.bottom.equalTo(updateButton.snp.bottom)
        }
        containView.layoutIfNeeded()
        show()
    }
    
    private func show() {
        containView!.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(UIScreen.main.bounds.height * 0.5 - containView!.height * 0.5)
        }
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.75, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
