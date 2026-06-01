//
//  ModifyIntroductionViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/24.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa

class ModifyIntroductionViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return ModifyIntroductionInput.self}
    
    fileprivate weak var textView: UITextView?
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
        
        let textViewContainV = UIView().addTo(superView: view).configure { (containView) in
            containView.backgroundColor = R.color.appColor._fae7ca()
        }.layout { (make) in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(view.height * 0.4)
        }
        
        textView = UITextView().addTo(superView: textViewContainV).configure({ (textView) in
            textView.backgroundColor = UIColor.clear
            textView.font = UIFont.size14
            textView.textColor = R.color.appColor._333333()
            let placeHolderLabel = UILabel().addTo(superView: textView).configure({ (label) in
                label.textColor = R.color.appColor._666666()
                label.text = NSLocalizedString("introduce_yourself", comment: "介绍一下你自己吧...")
                label.font = UIFont.size14
                label.sizeToFit()
            })
            textView.setValue(placeHolderLabel, forKey: "_placeholderLabel")
        }).layout(snapKitMaker: { (make) in
            make.edges.equalToSuperview().inset(20)
        })
        AccountInfoManager.shared.introduction.asDriver().drive(textView!.rx.text).disposed(by: disposeBag)
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let modifyIntroductionOutput = output as! ModifyIntroductionOutput
        modifyIntroductionOutput.modifyResult.drive(onNext: { [unowned self] success in
            guard success else {
                BlockyHUD.showText(NSLocalizedString("modify_fail_retry", comment: "修改失败，请重试"), inView: self.view)
                return
            }
            AnalysisManager.trackEvent(AnalysisManager.Event.more_pers_suc)
            BlockyHUD.showText(NSLocalizedString("modify_success", comment: "修改成功"), inView: self.view)
            AppDelegate.globalServive().popViewModel(animated: true)
        }).disposed(by: disposeBag)
    }
}

struct ModifyIntroductionInput: ViewToViewModelInput {
    let textViewInput: Driver<String>
    let doneTap: Driver<()>
    
    init(view: BaseViewController) {
        let modifyIntroductionView = view as! ModifyIntroductionViewController
        textViewInput = modifyIntroductionView.textView!.rx.text.orEmpty.asDriver()
        doneTap = modifyIntroductionView.doneButton!.rx.tap.asDriver()
    }
}
