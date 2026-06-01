//
//  UnbindPhoneViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/24.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UnbindPhoneViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return UnbindPhoneInput.self}
    
    fileprivate weak var unbindBtn: UIButton?
    
    fileprivate let verificationCodeSubject = PublishSubject<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func createAndLayoutChildViews() {
        super.createAndLayoutChildViews()
        
        let locationContainV = UIView()
        locationContainV.backgroundColor = R.color.appColor._fae7ca()
        view.addSubview(locationContainV)
        locationContainV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(50)
        }
        
        let locationLab = UILabel().config(text: "所在地", textColor: R.color.appColor._333333(), font: UIFont.size15)
        locationContainV.addSubview(locationLab)
        locationLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        let locationDetailLab = UILabel().config(text: "中国大陆 +86", textColor: R.color.appColor._666666())
        locationContainV.addSubview(locationDetailLab)
        locationDetailLab.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        
        let phoneContainV = UIView()
        phoneContainV.backgroundColor = R.color.appColor._fae7ca()
        view.addSubview(phoneContainV)
        phoneContainV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(locationContainV.snp.bottom).offset(1)
            make.height.equalTo(50)
        }
        
        let phoneLab = UILabel().config(text: "手机号", textColor: R.color.appColor._333333(), font: UIFont.size15)
        phoneContainV.addSubview(phoneLab)
        phoneLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        let phoneDetailLab = UILabel().config(text: AccountInfoManager.shared.phone.value, textColor: R.color.appColor._666666())
        phoneContainV.addSubview(phoneDetailLab)
        phoneDetailLab.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        
        
        unbindBtn = UIButton().addTo(superView: view).configure { (button) in
            button.setDefaultStyle()
            button.setTitle("解绑手机", for: .normal)
        }.layout { (make) in
            make.top.equalTo(phoneContainV.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(14)
            make.height.equalTo(50)
        }
        unbindBtn!.rx.tap.subscribe(onNext: {
            let unbindPhoneAlertV = UnbindPhoneAlertView(frame: UIScreen.main.bounds)
            unbindPhoneAlertV.delegate = self
            unbindPhoneAlertV.showIn(AppDelegate.delegate().window!)
        }).disposed(by: disposeBag)
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let unbindPhoneOutput = output as! UnbindPhoneOutput
        unbindPhoneOutput.unbindResult.drive(onNext: { [unowned self] (result) in
            switch result {
            case .success:
                BlockyHUD.showText("解绑成功", inView: self.view)
                AppDelegate.globalServive().popViewModel(animated: true)
            case let .fail(error):
                self.showAlert(withError: error)
            }
        }).disposed(by: disposeBag)
    }
}

extension UnbindPhoneViewController: UnbindPhoneAlertViewDelegate {
    func unbindPhoneAlertView(_ unbindPhoneView: UnbindPhoneAlertView, didUnbindedWith verificationCode: String) {
        unbindPhoneView.dismissFromSuperView()
        verificationCodeSubject.onNext(verificationCode)
    }
}

struct UnbindPhoneInput: ViewToViewModelInput {
    let verificationCodeInput: Driver<String>
    let unbindTap: Driver<()>
    init(view: BaseViewController) {
        let unbindPhoneView = view as! UnbindPhoneViewController
        verificationCodeInput = unbindPhoneView.verificationCodeSubject.asDriver(onErrorJustReturn: "")
        unbindTap = unbindPhoneView.unbindBtn!.rx.tap.asDriver()
    }
}
