//
//  RegisterSucceedAlertView.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/20.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift

class RegisterSucceedAlertView: UIView {

    private let disposeBag = DisposeBag()
    private weak var containView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.45)
        
        containView = UIView().addTo(superView: self).configure { (view) in
            view.backgroundColor = R.color.appColor._e7c99e()
        }.layout { (make) in
            make.size.equalTo(CGSize(width: 260, height: 270))
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(-270)
        }
        
        let topView = UIView().addTo(superView: containView!).configure { (view) in
            view.backgroundColor = R.color.appColor._0ab950()
        }.layout { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(93)
        }
        
        let doneImageV = UIImageView(image: R.image.common_op_done()).addTo(superView: topView).layout { (make) in
            make.height.width.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(17)
        }
        
        let doneLab = UILabel().addTo(superView: topView).configure { (label) in
            label.text = NSLocalizedString("register_success", comment: "注册成功")
            label.textColor = R.color.appColor._fffefe()
            label.font = UIFont.size18
        }.layout { (make) in
            make.top.equalTo(doneImageV.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        let accountPasswordArray = AccountInfoManager.shared.accountPassword()
        let userNameLab = UILabel().addTo(superView: containView!).configure { (label) in
            label.text = NSLocalizedString("account", comment: "账号: ") + ": " + (accountPasswordArray?.first ?? "")
            label.textColor = R.color.appColor._333333()
            label.font = UIFont.size15
        }.layout { (make) in
            make.top.equalTo(topView.snp.bottom).offset(19)
            make.centerX.equalToSuperview()
        }
        
        let passwordLab = UILabel().addTo(superView: containView!).configure { (label) in
            label.text = NSLocalizedString("password", comment: "密  码: ") + ": " + (accountPasswordArray?.last ?? "")
            label.textColor = R.color.appColor._333333()
            label.font = UIFont.size15
        }.layout { (make) in
            make.top.equalTo(userNameLab.snp.bottom).offset(14)
            make.centerX.equalTo(userNameLab)
        }
        
        let remindLab = UILabel().addTo(superView: containView!).configure { (label) in
            label.text = NSLocalizedString("remember_your_account_password", comment: "*请牢记你的用户名和密码")
            label.textColor = R.color.appColor._666666()
            label.font = UIFont.size12
        }.layout { (make) in
            make.top.equalTo(passwordLab.snp.bottom).offset(26)
            make.centerX.equalTo(userNameLab)
        }
        
        let closeBtn = UIButton().addTo(superView: containView!).configure({ (button) in
            button.setBackgroundImage(R.image.common_btn_second(), for: .normal)
            button.setBackgroundImage(R.image.common_btn_highlight(), for: .highlighted)
            button.setBackgroundImage(R.image.common_btn_disable(), for: .disabled)
            button.titleLabel?.font = UIFont.size16
            button.setTitleColor(R.color.appColor.white(), for: .normal)
            button.setTitle(R.string.localizable.common_cancel(), for: .normal)
        }).layout(snapKitMaker: { (make) in
            make.size.equalTo(CGSize(width: 75, height: 44))
            make.left.equalToSuperview().offset(10)
            make.top.equalTo(remindLab.snp.bottom).offset(20)
        })
        closeBtn.rx.tap.subscribe(onNext: {[unowned self] in
            self.removeFromSuperview()
        }).disposed(by: disposeBag)
        
        let snapshotBtn = UIButton().addTo(superView: containView!).configure({ (button) in
            button.setDefaultStyle()
            button.setTitle(R.string.localizable.save_screenshot(), for: .normal)
        }).layout(snapKitMaker: { (make) in
            make.left.equalTo(closeBtn.snp.right).offset(10)
            make.right.equalToSuperview().inset(10)
            make.centerY.height.equalTo(closeBtn)
        })
        containView!.layoutIfNeeded()
        snapshotBtn.rx.tap.subscribe(onNext: { [weak self] in
            if let image = self?.screenSnapshot() {
                self?.saveImageToAlbum(image: image)
            }
        }).disposed(by: disposeBag)
        
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
    
    private func dismiss() {
        containView!.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(UIScreen.main.bounds.height)
        }
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }) { (finish) in
            if finish {
                self.removeFromSuperview()
            }
        }
        
    }
    
    private func screenSnapshot() -> UIImage? {
        let window = AppDelegate.keyWindow()
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        window.layer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func saveImageToAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func saveImage(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        guard let _ = error else {
            BlockyHUD.showText(NSLocalizedString("save_success", comment: "保存成功"), inView: AppDelegate.keyWindow())
            dismiss()
            return
        }
        BlockyHUD.showText(NSLocalizedString("save_fail_retry", comment: "保存失败, 请重试"), inView: AppDelegate.keyWindow())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
