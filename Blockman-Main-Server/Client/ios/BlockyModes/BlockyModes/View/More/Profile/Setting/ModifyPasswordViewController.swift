//
//  ModifyPasswordViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/24.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ModifyPasswordViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return ModifyPasswordInput.self}
    
    private(set) weak var originPwdTextField: UITextField?
    private(set) weak var newPwdTextField: UITextField?
    private(set) weak var doublePwdTextField: UITextField?
    private(set) weak var doneButton: UIButton?
    private(set) var passwordVerifyResult: VerifyResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func createAndLayoutChildViews() {
        
        let doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: 65, height: 30)).configure({ (button) in
            button.setDefaultStyle()
            button.setTitle(NSLocalizedString("done", comment: "完成"), for: .normal)
        })
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        self.doneButton = doneButton
        
        originPwdTextField = UITextField().addTo(superView: view).configure({ (textField) in
            textField.setDefaultStyle(placeHolder: NSLocalizedString("input_origin_password", comment: "输入原密码"), isSecure: true)
        }).layout(snapKitMaker: { (make) in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(50)
        })
        
        newPwdTextField = UITextField().addTo(superView: view).configure({ (textField) in
            textField.setDefaultStyle(placeHolder: NSLocalizedString("input_new_password", comment: "输入新密码"), isSecure: true)
        }).layout(snapKitMaker: { [unowned self] (make) in
            make.size.centerX.equalTo(self.originPwdTextField!)
            make.top.equalTo(self.originPwdTextField!.snp.bottom).offset(1)
        })
        
        doublePwdTextField = UITextField().addTo(superView: view).configure({ (textField) in
            textField.setDefaultStyle(placeHolder: NSLocalizedString("double_input_new_password", comment: "重复新密码"), isSecure: true)
        }).layout(snapKitMaker: { [unowned self] (make) in
            make.size.centerX.equalTo(self.originPwdTextField!)
            make.top.equalTo(self.newPwdTextField!.snp.bottom).offset(1)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resignTextFieldsResponder()
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let modifyPwdOutput = output as! ModifyPasswordOutput
        modifyPwdOutput.modifyValid.drive(doneButton!.rx.isEnabled).disposed(by: disposeBag)
        modifyPwdOutput.newPasswordValid.drive(onNext: { [weak self] in
            self?.passwordVerifyResult = $0
        }).disposed(by: disposeBag)
        
        modifyPwdOutput.modifyResult.drive(onNext: { (result) in
            switch result {
            case .success:
                AnalysisManager.trackEvent(AnalysisManager.Event.more_chpass_suc)
                AppDelegate.globalServive().popViewModel(animated: true)
                DebugLog("修改成功")
            case let .fail(error):
                self.showAlert(withError: error)
            }
        }).disposed(by: disposeBag)
    }
    
    fileprivate func resignTextFieldsResponder() {
        originPwdTextField?.resignFirstResponder()
        newPwdTextField?.resignFirstResponder()
        doublePwdTextField?.resignFirstResponder()
    }
}

struct ModifyPasswordInput: ViewToViewModelInput {
    
    let originPwdInput: Driver<String>
    let newPwdInput: Driver<String>
    let doublePwdInput: Driver<String>
    let doneTap: Driver<Bool>
    
    init(view: BaseViewController) {
        let modifyPwdView = view as! ModifyPasswordViewController
        originPwdInput = modifyPwdView.originPwdTextField!.rx.text.orEmpty.asDriver().throttle(0.5).distinctUntilChanged()
        newPwdInput = modifyPwdView.newPwdTextField!.rx.text.orEmpty.asDriver().throttle(0.5).distinctUntilChanged()
        doublePwdInput = modifyPwdView.doublePwdTextField!.rx.text.orEmpty.asDriver().throttle(0.5).distinctUntilChanged()
        doneTap = modifyPwdView.doneButton!.rx.tap.asDriver().throttle(0.5).map({
            modifyPwdView.resignTextFieldsResponder()
            switch modifyPwdView.passwordVerifyResult! {
            case let .failed(message: error):
                BlockyAlert.show(title: R.string.localizable.notification(), message: error)
                return false
            default:
                return true
            }
        })
    }
}
