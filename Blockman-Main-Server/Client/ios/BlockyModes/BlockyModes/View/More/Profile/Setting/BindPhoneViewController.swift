//
//  BindPhoneViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/24.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class BindPhoneViewController: BaseViewController {

    private(set) weak var phoneTextField: UITextField?
    private(set) weak var verifyCodeTextField: UITextField?
    private(set) weak var fetchVerifyCodeButton: CaptchaCountDownButton?
    private(set) weak var doneBindButton: UIButton?
    
    override var inputType: ViewToViewModelInput.Type? {return BindPhoneInput.self}
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func createAndLayoutChildViews() {
        super.createAndLayoutChildViews()
        
        let phonePrefixLab = UILabel().config(text: "中国大陆 +86", textColor: R.color.appColor._333333(), textAlignment: .center , font: UIFont.size14)
        phonePrefixLab.backgroundColor = R.color.appColor._fae7ca()
        view.addSubview(phonePrefixLab)
        phonePrefixLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 123, height: 50))
        }
        
        phoneTextField = UITextField().addTo(superView: view).configure { (textField) in
            textField.setDefaultStyle(placeHolder: "输入手机号码", isSecure: false)
        }.layout(snapKitMaker: { (make) in
            make.top.height.equalTo(phonePrefixLab)
            make.left.equalTo(phonePrefixLab.snp.right).offset(1)
            make.right.equalToSuperview().offset(-16)
        })

        verifyCodeTextField = UITextField().addTo(superView: view).configure { (textField) in
            textField.setDefaultStyle(placeHolder: "输入验证码", isSecure: false)
        }.layout(snapKitMaker: { (make) in
            make.left.equalTo(phonePrefixLab)
            make.top.equalTo(phonePrefixLab.snp.bottom).offset(10)
            make.size.equalTo(CGSize(width: 180, height: 50))
        })
        
        fetchVerifyCodeButton = CaptchaCountDownButton(countDown: 60).addTo(superView: view).configure({ (button) in
            button.setDefaultStyle(fontSize: 15)
            button.setTitle("获取验证码", for: .normal)
        }).layout(snapKitMaker: { (make) in
            make.left.equalTo(verifyCodeTextField!.snp.right).offset(10)
            make.top.height.equalTo(verifyCodeTextField!)
            make.right.equalToSuperview().offset(-16)
        })

        doneBindButton = UIButton().addTo(superView: view).configure({ (button) in
            button.setDefaultStyle(fontSize: 15)
            button.setTitle("确定", for: .normal)
        }).layout(snapKitMaker: { (make) in
            make.top.equalTo(verifyCodeTextField!.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(50)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        phoneTextField?.resignFirstResponder()
        verifyCodeTextField?.resignFirstResponder()
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let bindPhoneOutput = output as! BindPhoneOutput
        
        bindPhoneOutput.phoneValid.drive(fetchVerifyCodeButton!.rx.isEnabled).disposed(by: disposeBag)
        bindPhoneOutput.doneVerifyValid.drive(doneBindButton!.rx.isEnabled).disposed(by: disposeBag)
        
        bindPhoneOutput.fetchVerificationCodeResult.drive(onNext: { [unowned self] (result) in
            switch result {
            case .success:
                BlockyHUD.showText("验证码发送成功", inView: self.view)
            case let .fail(error):
                self.showAlert(withError: error)
            }
        }).disposed(by: disposeBag)
        
        bindPhoneOutput.bindResult.drive(onNext: { [unowned self] (result) in
            switch result {
            case .success:
                AnalysisManager.trackEvent(AnalysisManager.Event.more_moi_suc)
                BlockyHUD.showText("绑定成功", inView: self.view)
                AppDelegate.globalServive().popViewModel(animated: true)
            case let .fail(error):
                self.showAlert(withError: error)
            }
        }).disposed(by: disposeBag)
    }
}

struct BindPhoneInput: ViewToViewModelInput {
    let phoneInput: Driver<String>
    let verifyCodeInput: Driver<String>
    let fetchVerificationCodeTap: Driver<()>
    let doneVerifyTap: Driver<()>
    
    init(view: BaseViewController) {
        let bindPhoneView = view as! BindPhoneViewController
        phoneInput = bindPhoneView.phoneTextField!.rx.text.orEmpty.asDriver().throttle(0.3).distinctUntilChanged()
        verifyCodeInput = bindPhoneView.verifyCodeTextField!.rx.text.orEmpty.asDriver().throttle(0.3).distinctUntilChanged()
        doneVerifyTap = bindPhoneView.doneBindButton!.rx.tap.asDriver().throttle(0.5).do(onNext: {
            bindPhoneView.phoneTextField!.resignFirstResponder()
            bindPhoneView.verifyCodeTextField!.resignFirstResponder()
        })
        fetchVerificationCodeTap = bindPhoneView.fetchVerifyCodeButton!.rx.tap.asDriver()
    }
}
