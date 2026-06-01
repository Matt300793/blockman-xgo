//
//  ProfileInfoView.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/23.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift

protocol ProfileInfoViewDelegate: class {
    func profileViewDidTap(_ profileView: ProfileInfoView)
}

class ProfileInfoView: UIView {
    
    weak var delegate: ProfileInfoViewDelegate?
    let disposeBag = DisposeBag()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        
        let topBackgroundImageV = UIImageView(image: R.image.profile_top_bg())
        topBackgroundImageV.isUserInteractionEnabled = true
        self.addSubview(topBackgroundImageV)
        topBackgroundImageV.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(142)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        topBackgroundImageV.addGestureRecognizer(tap)
        
        let userPortraitV = UserPortraitView()
        topBackgroundImageV.addSubview(userPortraitV)
        userPortraitV.snp.makeConstraints { (make) in
            make.width.height.equalTo(63)
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-10)
        }
        AccountInfoManager.shared.portraiUrl.asObservable().subscribe(onNext: {
            userPortraitV.portraitWithUrlString($0, placeHolder: R.image.common_default_userimage())
        }).disposed(by: disposeBag)
        
        let userNameLab = UILabel().config(text: "", textColor: UIColor.white, font: UIFont.boldSize15)
        topBackgroundImageV.addSubview(userNameLab)
        userNameLab.snp.makeConstraints { (make) in
            make.left.equalTo(userPortraitV.snp.right).offset(10)
            make.centerY.equalTo(userPortraitV.snp.centerY).offset(-margin_16)
        }
        AccountInfoManager.shared.nickname.asObservable().bind(to: userNameLab.rx.text).disposed(by: disposeBag)
        
        let genderImageV = UIImageView(image: R.image.common_male())
        topBackgroundImageV.addSubview(genderImageV)
        genderImageV.snp.makeConstraints { (make) in
            make.centerY.equalTo(userNameLab)
            make.left.equalTo(userNameLab.snp.right).offset(5)
        }
        AccountInfoManager.shared.genderImage.asObservable().bind(to: genderImageV.rx.image).disposed(by: disposeBag)
        
        let vipLevelImageView = UIImageView().addTo(superView: topBackgroundImageV).layout { (make) in
            make.left.equalTo(genderImageV.snp.right).offset(10)
            make.centerY.equalTo(genderImageV)
        }
        AccountInfoManager.shared.vip.asObservable().subscribe(onNext: {
            vipLevelImageView.image = UIImage(named: "common_vip_" + "\($0)")
        }).disposed(by: disposeBag)
        
        let buttonConfig = {(button: UIButton) in
            button.isUserInteractionEnabled = false
            button.titleLabel?.font = UIFont.size13
            button.contentHorizontalAlignment = .left
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitle("--", for: .normal)
        }
        
        let diamondView = UIButton().addTo(superView: self).configure(buttonConfig).configure { (button) in
            button.setImage(R.image.common_diamond(), for: .normal)
            }.layout { (make) in
                make.left.equalTo(userNameLab)
                make.top.equalTo(userNameLab.snp.bottom).offset(margin_16)
                make.width.greaterThanOrEqualTo(70)
        }
        AccountPropertyManager.shared.diamonds.asDriver().map{ String($0) }.drive(diamondView.rx.title()).disposed(by: disposeBag)
        
        let goldView = UIButton().addTo(superView: self).configure(buttonConfig).configure { (button) in
            button.setImage(R.image.common_gold(), for: .normal)
            }.layout { (make) in
                make.left.equalTo(diamondView.snp.right).offset(10)
                make.width.greaterThanOrEqualTo(70)
                make.centerY.equalTo(diamondView.snp.centerY)
        }
        AccountPropertyManager.shared.golds.asDriver().map{ String($0) }.drive(goldView.rx.title()).disposed(by: disposeBag)
        
        let arrowImageV = UIImageView(image: R.image.common_jump_arrow())
        topBackgroundImageV.addSubview(arrowImageV)
        arrowImageV.snp.makeConstraints { (make) in
            make.centerY.equalTo(userPortraitV)
            make.right.equalToSuperview().offset(-16)
        }
        
        let registerButton = UIButton().addTo(superView: topBackgroundImageV).configure { (button) in
            button.setDefaultStyle(fontSize: 13)
            button.setTitle(NSLocalizedString("register", comment: "注册"), for: .normal)
        }.layout { (make) in
            make.size.equalTo(CGSize(width: 65, height: 20))
            make.right.equalToSuperview().offset(-margin_16)
            make.centerY.equalTo(userPortraitV).offset(-margin_14)
        }
        registerButton.rx.tap.subscribe(onNext: {
            AppDelegate.globalServive().pushViewModel(AccountPageViewModel.self, params: AccountPageController.AccountType.register, animated: true)
        }).disposed(by: disposeBag)
        
        let loginButton = UIButton().addTo(superView: topBackgroundImageV).configure { (button) in
            button.setDefaultStyle(fontSize: 13)
            button.setTitle(NSLocalizedString("log_in", comment: "登录"), for: .normal)
        }.layout { (make) in
            make.size.right.equalTo(registerButton)
            make.top.equalTo(registerButton.snp.bottom).offset(margin_10)
        }
        loginButton.rx.tap.subscribe(onNext: {
            AppDelegate.globalServive().pushViewModel(AccountPageViewModel.self, params: AccountPageController.AccountType.login, animated: true)
        }).disposed(by: disposeBag)
        
        let introductionView = UIView()
        introductionView.backgroundColor = R.color.appColor._0d634c()
        self.addSubview(introductionView)
        introductionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(topBackgroundImageV.snp.bottom)
            make.height.equalTo(28)
        }
        
        let introductionLab = UILabel().config(text: "", textColor: R.color.appColor.text_normal())
        introductionView.addSubview(introductionLab)
        introductionLab.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
        }
        AccountInfoManager.shared.introduction.asObservable().map {
            NSLocalizedString("introduction", comment: "简介: ") + $0
            }.bind(to: introductionLab.rx.text).disposed(by: disposeBag)
        
        // observe account status
        AccountStatusManager.shared.statusVariable.asObservable().subscribe(onNext: { status in
            switch status {
            case .logIn:
                tap.isEnabled = true
                arrowImageV.isHidden = false
                diamondView.isHidden = false
                goldView.isHidden = false
                registerButton.isHidden = true
                loginButton.isHidden = true
            case .visit:
                tap.isEnabled = false
                arrowImageV.isHidden = true
                diamondView.isHidden = true
                goldView.isHidden = true
                registerButton.isHidden = false
                loginButton.isHidden = false
            }
        }).disposed(by: disposeBag)
    }
    
    @objc func didTap() {
        self.delegate?.profileViewDidTap(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
