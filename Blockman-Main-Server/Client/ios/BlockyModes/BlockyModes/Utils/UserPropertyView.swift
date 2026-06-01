//
//  UserPropertyView.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/11.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserPropertyView: UIView {

    private let disposeBag = DisposeBag()
    
    required init(frame: CGRect, showRecharge: Bool = true) {
        super.init(frame: frame)
        
        backgroundColor = R.color.appColor._00925a()
        
        let buttonConfig = {(button: UIButton) in
            button.isUserInteractionEnabled = false
            button.titleLabel?.font = UIFont.size14
            button.contentHorizontalAlignment = .left
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitle("--", for: .normal)
        }
        
        let diamondView = UIButton().addTo(superView: self).configure(buttonConfig).configure { (button) in
            button.setImage(R.image.common_diamond(), for: .normal)
        }.layout { (make) in
            make.left.equalToSuperview().offset(15)
            make.width.greaterThanOrEqualTo(70)
            make.centerY.equalToSuperview()
        }
        
        let goldView = UIButton().addTo(superView: self).configure(buttonConfig).configure { (button) in
            button.setImage(R.image.common_gold(), for: .normal)
        }.layout { (make) in
            make.left.equalTo(diamondView.snp.right).offset(10)
            make.width.greaterThanOrEqualTo(70)
            make.centerY.equalTo(diamondView.snp.centerY)
        }
        
        if showRecharge {
            // 充值按钮Title(R.string.localizable.recharge(), for: .normal)
            let rechargeButton = UIButton().addTo(superView: self).configure { (button) in
                button.setDefaultStyle(fontSize: 15)
                button.setTitle(R.string.localizable.top_up(), for: .normal)
            }.layout { (make) in
                make.size.equalTo(CGSize(width: 60, height: 27))
                make.right.equalToSuperview().offset(-margin_16)
                make.centerY.equalToSuperview()
            }
            rechargeButton.rx.tap.subscribe(onNext: {
                // TODO: 跳转到充值界面
                AnalysisManager.trackEvent(AnalysisManager.Event.more_topup)
                AppDelegate.globalServive().pushViewModel(RechargeViewModel.self, params: nil, animated: true)
            }).disposed(by: disposeBag)
            
            AccountStatusManager.shared.statusVariable.asDriver().map({
                $0 == AccountStatusManager.Status.visit
            })
            .drive(rechargeButton.rx.isHidden)
            .disposed(by: disposeBag)
        }
        
        AccountPropertyManager.shared.diamonds.asDriver().map{ String($0) }.drive(diamondView.rx.title()).disposed(by: disposeBag)
        AccountPropertyManager.shared.golds.asDriver().map{ String($0) }.drive(goldView.rx.title()).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
