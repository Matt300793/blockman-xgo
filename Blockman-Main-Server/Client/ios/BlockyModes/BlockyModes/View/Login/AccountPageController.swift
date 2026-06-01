//
//  AccountPageController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/19.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class AccountPageController: BaseViewController {
    
    public enum AccountType {
        case login
        case register
    }
    
   public static var isPresented: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = R.color.appColor.mainBackground()
        let backBtn = UIButton(frame: CGRect(x: 16, y: 35, width: 24, height: 24))
        backBtn.setBackgroundImage(R.image.common_nav_back(), for: .normal)
        view.addSubview(backBtn)
        backBtn.rx.tap.subscribe(onNext: {[unowned self] in
            if self.presentingViewController != nil {
                AppDelegate.globalServive().dismissViewModel(animated: true, completion: {
                    AccountPageController.isPresented = false
                })
            }else {
                AppDelegate.globalServive().popViewModel(animated: true)
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true , animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if presentingViewController != nil {
            navigationController?.setNavigationBarHidden(false , animated: true)
        }
    }
    
    override func createAndLayoutChildViews() {
        super.createAndLayoutChildViews()
        
        let defaultIcon : UIImageView = UIImageView(image: R.image.common_default_icon())
        view.addSubview(defaultIcon)
        defaultIcon.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 83, height: 57))
            make.topMargin.equalToSuperview().offset(54)
            make.centerX.equalToSuperview()
        }
        
        let defaultName = UILabel()
        defaultName.font = UIFont.boldSystemFont(ofSize: 15)
        defaultName.textAlignment = .center
        defaultName.textColor = R.color.appColor.text_normal()
        defaultName.text = "Blocky Mods"
        view.addSubview(defaultName)
        defaultName.snp.makeConstraints { (make) in
            make.top.equalTo(defaultIcon.snp.bottom).offset(10)
            make.centerX.equalTo(defaultIcon)
        }
        let loginController = LoginViewController(viewModelType: LoginViewModel.self)
        let registerController = RegisterViewController(viewModelType: RegisterViewModel.self)
        let pageController = UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        addChildViewController(pageController)
        view.addSubview(pageController.view)
        pageController.view.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(defaultName).offset(45)
        }
        pageController.setViewControllers([loginController], direction: .reverse, animated: false, completion: nil)
        
        let accountType = params as? AccountType ?? AccountType.login
        if accountType == AccountType.register {
            pageController.setViewControllers([registerController], direction: .forward, animated: false, completion: nil)
        }
        
        NotificationCenter.default.rx.notification(.BMRegisterControllerSwitchToLogin).subscribe(onNext: { _ in
            pageController.setViewControllers([loginController], direction: .reverse, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.BMLoginControllerSwitchToRegister).subscribe(onNext: { _ in
            pageController.setViewControllers([registerController], direction: .forward, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
}
