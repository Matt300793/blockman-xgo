//
//  ModifyNickNameViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/24.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa

class ModifyNickNameViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return ModifyNickNameInput.self}
    
    fileprivate weak var nicknameTextField: UITextField?
    fileprivate weak var doneButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func createAndLayoutChildViews() {
        
        let doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: 65, height: 30)).configure({ (button) in
            button.setDefaultStyle()
            button.setTitle(R.string.localizable.done(), for: .normal)
        })
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        self.doneButton = doneButton
        
        let textFieldContainV = UIView().addTo(superView: view).configure { (view) in
            view.backgroundColor = R.color.appColor._fae7ca()
        }.layout { (make) in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(50)
        }
        
        nicknameTextField = UITextField().addTo(superView: textFieldContainV).configure({ (textfield) in
            textfield.setDefaultStyle(placeHolder: NSLocalizedString("input_nickname", comment: "输入昵称"), isSecure: false)
        }).layout(snapKitMaker: { (make) in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(16)
            make.centerY.equalToSuperview()
        })
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let modifyNicknameOutput = output as! ModifyNickNameOutput
        
        modifyNicknameOutput.newNicknameValid.drive(doneButton!.rx.isEnabled).disposed(by: disposeBag)
//        modifyNicknameOutput.modifyResult.drive(onNext: { (code) in
//            switch code {
//            case .success:
//                return
//            case .nicknameExist:
//                print("改昵称已存在")
//            case .profileNotExist:
//                print("profile not exist")
//            default:
//                break
//            }
//        }).disposed(by: disposeBag)
    }
}

struct ModifyNickNameInput: ViewToViewModelInput {
    let nicknameInput: Driver<String>
    let doneTap: Driver<()>
    
    init(view: BaseViewController) {
        let modifyNicknameView = view as! ModifyNickNameViewController
        nicknameInput = modifyNicknameView.nicknameTextField!.rx.text.orEmpty.asDriver()
        doneTap = modifyNicknameView.doneButton!.rx.tap.asDriver()
    }
}
