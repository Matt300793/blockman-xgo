//
//  RegisterConfirmViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/19.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RegisterConfirmViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return RegisterConfirmInput.self}
    
    fileprivate weak var userImageV: UIImageView?
    fileprivate weak var uploadImageBtn: UIButton?
    fileprivate weak var nickNameInputView: UnderlineInputView?
    fileprivate weak var maleBtn: UIButton?
    fileprivate weak var femaleBtn: UIButton?
    fileprivate weak var doneBtn: UIButton?
    private let imagePicker = ImagePickerController()
    fileprivate var selectedImage = UIImage()
    fileprivate var genderSubject = PublishSubject<Int>()
    fileprivate var uploadImageSubject = PublishSubject<String>()
    
    override func viewDidLoad() {
         super.viewDidLoad()

        let backBtn = UIButton().addTo(superView: view).configure { (button) in
            button.setBackgroundImage(R.image.common_nav_back(), for: .normal)
        }.layout { (make) in
            make.top.equalToSuperview().offset(35)
            make.left.equalToSuperview().offset(margin_16)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        backBtn.rx.tap.subscribe(onNext: {
            BlockyAlert.show(title: R.string.localizable.notification(), message: NSLocalizedString("is_cancel_register", comment: "是否放弃注册?"), showCancel: true).done(closure: { _ in
                AppDelegate.globalServive().popToRootViewModel(animated: true)
            })
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalysisManager.trackEvent(AnalysisManager.Event.enter_useroage)
    }
    
    override func createAndLayoutChildViews() {
        view.backgroundColor = R.color.appColor.mainBackground()
        
        userImageV = UIImageView(image: R.image.common_default_userimage()).addTo(superView: view).layout { (make) in
            make.size.equalTo(CGSize(width: 55, height: 55))
            make.top.equalToSuperview().offset(82)
            make.left.equalToSuperview().offset(60)
        }
        
        uploadImageBtn = UIButton().addTo(superView: view).configure({ (button) in
            button.setDefaultStyle()
            button.setTitle(R.string.localizable.upload_portrait(), for: .normal)
        }).layout(snapKitMaker: { [unowned self] (make) in
            make.size.equalTo(CGSize(width: 57, height: 24))
            make.bottom.equalTo(self.userImageV!.snp.bottom)
            make.left.equalTo(self.userImageV!.snp.right).offset(10)
        })

        nickNameInputView = UnderlineInputView(frame: .zero, placeHolder: NSLocalizedString("input_nickname", comment: "输入昵称")).addTo(superView: view).layout(snapKitMaker: { [unowned self] (make) in
            make.left.right.equalToSuperview().inset(67)
            make.top.equalTo(self.userImageV!.snp.bottom).offset(40)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
        })
        
        let genderLab = UILabel().addTo(superView: view).configure({ (label) in
            label.textColor = R.color.appColor._fffefe()
            label.font = UIFont.size15
            label.text = R.string.localizable.gender()
        }).layout { [unowned self] (make) in
            make.top.equalTo(self.nickNameInputView!.snp.bottom).offset(20)
            make.left.equalTo(view.snp.centerX).offset(-120)
        }
        
        maleBtn = UIButton().addTo(superView: view).configure({ (button) in
            button.titleLabel?.font = UIFont.size15
            button.setTitleColor(R.color.appColor._FEFEFE(), for: .selected)
            button.setTitleColor(R.color.appColor.text_normal(), for: .normal)
            button.backgroundColor = R.color.appColor._007e5c()
            button.setTitle(R.string.localizable.male(), for: .normal)
        }).layout(snapKitMaker: { (make) in
            make.size.equalTo(CGSize(width: 115, height: 30))
            make.top.equalTo(genderLab.snp.bottom).offset(10)
            make.left.equalTo(genderLab)
        })
        
        femaleBtn = UIButton().addTo(superView: view).configure({ (button) in
            button.titleLabel?.font = UIFont.size15
            button.setTitleColor(R.color.appColor._FEFEFE(), for: .selected)
            button.setTitleColor(R.color.appColor.text_normal(), for: .normal)
            button.backgroundColor = R.color.appColor._007e5c()
            button.setTitle(R.string.localizable.female(), for: .normal)
        }).layout(snapKitMaker: { [unowned self] (make) in
            make.size.centerY.equalTo(self.maleBtn!)
            make.left.equalTo(self.maleBtn!.snp.right).offset(10)
        })
        
        doneBtn = UIButton().addTo(superView: view).configure({ (button) in
            button.setDefaultStyle()
            button.setTitle(R.string.localizable.done(), for: .normal)
            button.titleLabel?.font = UIFont.size16
        }).layout(snapKitMaker: { [unowned self] (make) in
            make.size.equalTo(CGSize(width: 240, height: 44))
            make.centerX.equalToSuperview()
            make.top.equalTo(self.maleBtn!.snp.bottom).offset(20)
        })
        
        // 点击上传头像
        uploadImageBtn!.rx.tap.subscribe(onNext: {[unowned self] in
            self.imagePicker.present(from: self, delegate: self, popoverSourceViewForIPad: self.uploadImageBtn)
        }).disposed(by: disposeBag)
        
        // 选择男
        maleBtn!.rx.tap.asDriver().do(onNext: { [unowned self] in
            self.maleBtn!.isSelected = true
            self.genderSubject.onNext(1)
        }).map { false}.drive(self.femaleBtn!.rx.isSelected).disposed(by: disposeBag)
        
        // 选择女
        femaleBtn!.rx.tap.asDriver().do(onNext: { [unowned self] in
            self.femaleBtn!.isSelected = true
            self.genderSubject.onNext(2)
        }).map { false}.drive(self.maleBtn!.rx.isSelected).disposed(by: disposeBag)
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let registerConfirmOutput = output as! RegisterConfirmOutput
        
        registerConfirmOutput.nicknameValid.map {[unowned self] in $0 && (self.maleBtn!.isSelected || self.femaleBtn!.isSelected)}.drive(doneBtn!.rx.isEnabled).disposed(by: disposeBag)
        maleBtn!.rx.tap.asDriver().withLatestFrom(registerConfirmOutput.nicknameValid).drive(doneBtn!.rx.isEnabled).disposed(by: disposeBag)
        femaleBtn!.rx.tap.asDriver().withLatestFrom(registerConfirmOutput.nicknameValid).drive(doneBtn!.rx.isEnabled).disposed(by: disposeBag)
        
        registerConfirmOutput.uploadResult.drive(onNext: { [unowned self] (isValid) in
            if isValid {
                BlockyHUD.showText(NSLocalizedString("upload_success", comment: "上传成功"), inView: self.view)
                AnalysisManager.trackEvent(AnalysisManager.Event.more_head_suc)
                self.userImageV!.image = self.selectedImage
            }else {
                BlockyHUD.showText(NSLocalizedString("upload_fail", comment: "上传失败，请重试"), inView: self.view)
            }
        }).disposed(by: disposeBag)
        
        registerConfirmOutput.registerConfirmResult.drive(onNext: { (result) in
            switch result {
            case .success:
                if self.presentingViewController != nil {
                    AppDelegate.globalServive().dismissViewModel(animated: true, completion: {AccountPageController.isPresented = false})
                }else {
                    AppDelegate.globalServive().popToRootViewModel(animated: true)
                }
                RegisterSucceedAlertView().addTo(superView: AppDelegate.keyWindow()).layout(snapKitMaker: { (make) in
                    make.edges.equalToSuperview()
                })
            case let .fail(error):
                AnalysisManager.trackEvent(AnalysisManager.Event.reg_failed, parameters: ["code" : String(error.rawValue)])
                self.showAlert(withError: error)
            }
        }).disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nickNameInputView!.resignResponder()
    }
}

struct RegisterConfirmInput: ViewToViewModelInput {
    
    let uidToken: (String, String, Bool)
    let uploadImageInput: Driver<String>
    let nicknameInput: Driver<String>
    let genderInput: Driver<Int>
    let doneTap: Driver<()>
    
    init(view: BaseViewController) {
        let registerConfirmView = view as! RegisterConfirmViewController
        uidToken = registerConfirmView.params as! (String, String, Bool)
        uploadImageInput = registerConfirmView.uploadImageSubject.asDriver(onErrorJustReturn: "")
        nicknameInput = registerConfirmView.nickNameInputView!.textField.rx.text.orEmpty.asDriver()
        genderInput = registerConfirmView.genderSubject.asDriver(onErrorJustReturn: 1)
        doneTap = registerConfirmView.doneBtn!.rx.tap.asDriver().do(onNext: {
            registerConfirmView.nickNameInputView!.resignResponder()
        })
    }
}

extension RegisterConfirmViewController: ImagePickerControllerDelegate {
    func imagePickerDidPickedImage(_ image: PickedImage) {
        selectedImage = image.image
        uploadImageSubject.onNext(image.fileURLString)
    }
}
