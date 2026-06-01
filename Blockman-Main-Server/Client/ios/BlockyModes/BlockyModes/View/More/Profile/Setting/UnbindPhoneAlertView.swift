//
//  UnbindPhoneAlertView.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/29.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol UnbindPhoneAlertViewDelegate: class {
    func unbindPhoneAlertView(_ unbindPhoneView: UnbindPhoneAlertView, didUnbindedWith verificationCode: String)
}

class UnbindPhoneAlertView: UIView {

    weak var delegate: UnbindPhoneAlertViewDelegate?
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.25)
        
        let containView = UIView().addTo(superView: self).configure { (view) in
            view.backgroundColor = R.color.appColor._fae7ca()
            view.width = 270
        }
        
        let verificationCodeTextFiled = UITextField().addTo(superView: containView).configure { (textField) in
            textField.setDefaultStyle(placeHolder: "输入验证码", isSecure: false)
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = R.color.appColor._aaaaaa().cgColor
            textField.width = containView.width * 0.55
            textField.height = 50
            textField.x = 20
            textField.y = 35
        }
        
        let fetchCodeBtn = CaptchaCountDownButton(countDown: 60).addTo(superView: containView).configure({ (button) in
            
            button.setTitle("获取验证码", for: .normal)
            button.width = containView.width - verificationCodeTextFiled.width - 40 - 10
            button.height = verificationCodeTextFiled.height
            button.centerY = verificationCodeTextFiled.centerY
            button.x = verificationCodeTextFiled.maxX + 10
        })
        
        containView.addSubview(fetchCodeBtn)
        
        let horizontalSeparatorV = UIView(frame: CGRect(x: 0, y: fetchCodeBtn.maxY + 15, width: containView.width, height: 1))
        horizontalSeparatorV.backgroundColor = R.color.appColor._e7c99e()
        containView.addSubview(horizontalSeparatorV)
        
        let cancelBtn = UIButton(frame: CGRect(x: 0, y: horizontalSeparatorV.maxY, width: containView.width * 0.5 - 0.5, height: 46))
        cancelBtn.backgroundColor = R.color.appColor._fae7ca()
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(R.color.appColor._666666(), for: .normal)
        cancelBtn.titleLabel?.font = UIFont.size18
        containView.addSubview(cancelBtn)
        cancelBtn.rx.tap.subscribe(onNext: {
            self.dismissFromSuperView()
        }).disposed(by: disposeBag)
        
        let doneBtn = UIButton(frame: CGRect(x: cancelBtn.maxX + 1, y: cancelBtn.y, width: cancelBtn.width, height: cancelBtn.height))
        doneBtn.backgroundColor = cancelBtn.backgroundColor
        doneBtn.setTitleColor(R.color.appColor._0ab950(), for: .normal)
        doneBtn.setTitleColor(R.color.appColor._aaaaaa(), for: .disabled)
        doneBtn.titleLabel?.font = cancelBtn.titleLabel?.font
        doneBtn.setTitle("确定", for: .normal)
        containView.addSubview(doneBtn)
        
        let verticalSeparatorView = UIView(frame: CGRect(x: cancelBtn.maxX, y: cancelBtn.y, width: 1, height: cancelBtn.height))
        verticalSeparatorView.backgroundColor = horizontalSeparatorV.backgroundColor
        containView.addSubview(verticalSeparatorView)
        
        containView.height = cancelBtn.maxY
        containView.center = self.center
        
        verificationCodeTextFiled.rx.text.orEmpty.asDriver().map {
            VerifyServer.verify(verificationCode: $0).isValid
        }.drive(doneBtn.rx.isEnabled).disposed(by: disposeBag)
        
        // 获取验证码
        fetchCodeBtn.rx.tap.flatMap {
            UserNetServer.fetchVerificationCode(phone: AccountInfoManager.shared.phone.value, type: .unbindPhone)
        }.subscribe().disposed(by: disposeBag)
        
        // 确定按钮点击
        doneBtn.rx.tap.subscribe(onNext: {
            self.delegate?.unbindPhoneAlertView(self, didUnbindedWith: verificationCodeTextFiled.text!)
        }).addDisposableTo(disposeBag)
    }
    
    func showIn(_ superView: UIView) {
        superView.addSubview(self)
    }
    
    func dismissFromSuperView() {
        self.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
