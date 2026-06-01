//
//  BlockyAlert.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/11/7.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class BlockyAlert: UIView {
    
    private var title: String?
    private var message: String?
    private var showCancel: Bool
    private var cancelClosure: (() -> Void)?
    private var doneClosure: ((BlockyAlert) -> Void)?
    private let disposeBag = DisposeBag()
    
    @discardableResult
    class func show(title: String? = nil, message: String?, showCancel: Bool = false) -> BlockyAlert {
        let alert = BlockyAlert.init(title: title, message: message, showCancel: showCancel).show(in: AppDelegate.keyWindow())
        return alert
    }
    
    required init(title: String?, message: String?, showCancel: Bool = false) {
        self.title = title
        self.message = message
        self.showCancel = showCancel
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    func show(in superView: UIView) -> Self {
        self.addTo(superView: superView).layout { (make) in
            make.edges.equalToSuperview()
            }.show()
        return self
    }
    
    @discardableResult
    func done(closure: @escaping (BlockyAlert) -> Void) -> Self {
        doneClosure = closure
        return self
    }
    
    @discardableResult
    func cancel(closure: @escaping () -> Void) -> Self {
        cancelClosure = closure
        return self
    }
    
    private func show() {
        transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1.0
            self.transform = .identity
        }
    }
    
    private func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.0
            self.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
        }, completion: { (finish) in
            if finish {
                self.removeFromSuperview()
            }
        })
    }
    
    private func commonInit() {
        
        alpha = 0.0
        transform = .identity
        backgroundColor = UIColor.black.withAlphaComponent(0.35)
        
        let containView = UIView().addTo(superView: self).configure { (containView) in
            containView.backgroundColor = R.color.appColor._fae7ca()
            }.layout { (make) in
                make.center.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.75)
                self.layoutIfNeeded()
        }
        
        let titleLabel = UILabel().addTo(superView: containView).configure { (titleLabel) in
            titleLabel.font = UIFont.boldSize18
            titleLabel.textColor = R.color.appColor._333333()
            titleLabel.text = title
            titleLabel.textAlignment = .center
            }.layout { (make) in
                make.left.top.right.equalToSuperview().inset(margin_16)
        }
        
        let messageLabel = UILabel().addTo(superView: containView).configure { (messageLabel) in
            messageLabel.font = UIFont.size15
            messageLabel.textColor = R.color.appColor._666666()
            messageLabel.numberOfLines = 0
            messageLabel.text = message
            messageLabel.textAlignment = .center
            }.layout { (make) in
                make.left.right.equalToSuperview().inset(margin_16)
                make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }
        
        let horizontalSeparator = UIView().addTo(superView: containView).configure { (horizontal) in
            horizontal.backgroundColor = R.color.appColor._e7c99e()
            }.layout { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(messageLabel.snp.bottom).offset(20)
                make.height.equalTo(1)
        }
        
        let doneButton = UIButton().addTo(superView: containView).configure { (cancelButton) in
            cancelButton.titleLabel?.font = UIFont.size15
            cancelButton.setTitleColor(R.color.appColor._0ab950(), for: .normal)
            cancelButton.setTitle(R.string.localizable.done(), for: .normal)
        }
        
        if !showCancel {
            doneButton.layout(snapKitMaker: { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(horizontalSeparator.snp.bottom)
                make.height.equalTo(36)
            }).rx.tap.subscribe(onNext: {[weak self] in
                self?.hide()
                guard let done = self?.doneClosure else {
                    return
                }
                done(self!) // 执行done 闭包
            }).disposed(by: disposeBag)
            
            containView.snp.makeConstraints { (make) in
                make.bottom.equalTo(doneButton.snp.bottom)
            }
            return
        }
        
        cancelClosure = hide
        
        let verticalSeparator = UIView().addTo(superView: containView).configure { (vertical) in
            vertical.backgroundColor = R.color.appColor._e7c99e()
            }.layout { (make) in
                make.top.equalTo(horizontalSeparator.snp.bottom)
                make.width.equalTo(1)
                make.height.equalTo(36)
                make.centerX.equalToSuperview()
        }
        
        UIButton().addTo(superView: containView).configure { (cancelButton) in
            cancelButton.titleLabel?.font = UIFont.size15
            cancelButton.setTitleColor(R.color.appColor._666666(), for: .normal)
            cancelButton.setTitle(R.string.localizable.common_cancel(), for: .normal)
            }.layout { (make) in
                make.left.equalToSuperview()
                make.top.height.equalTo(verticalSeparator)
                make.right.equalTo(verticalSeparator.snp.left)
            }.rx.tap.subscribe(onNext: {[weak self] in
                guard let cancel = self?.cancelClosure!() else {
                    return
                }
                cancel // 执行cancel 闭包
            }).disposed(by: disposeBag)
        
        doneButton.layout { (make) in
            make.left.equalTo(verticalSeparator.snp.right)
            make.top.height.equalTo(verticalSeparator)
            make.right.equalToSuperview()
            }.rx.tap.subscribe(onNext: {[weak self] in
                self?.hide()
                guard let done = self?.doneClosure else {
                    return
                }
                done(self!) // 执行done 闭包
            }).disposed(by: disposeBag)
        
        containView.snp.makeConstraints { (make) in
            make.bottom.equalTo(verticalSeparator.snp.bottom)
        }
    }
}
