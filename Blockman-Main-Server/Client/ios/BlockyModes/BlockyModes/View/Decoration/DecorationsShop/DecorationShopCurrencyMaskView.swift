//
//  DecorationShopCurrencyMaskView.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/11.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift

class DecorationShopCurrencyMaskView: UIControl {

    enum Currency: Int {
        case all = 0
        case diamond = 1
        case gold = 2
    }
    
    private let disposeBag = DisposeBag()
    
    public var selectedCurrency: Currency = .all
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.35)
        
        let containView = UIView().addTo(superView: self).configure { (view) in
            view.backgroundColor = R.color.appColor._e7c99e()
        }.layout { (make) in
            make.top.right.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(153)
        }
        
        let allButton = UIButton().addTo(superView: containView).configure { (button) in
            button.setBackgroundImage(R.image.decorationshop_all(), for: .normal)
            }.layout { (make) in
                make.top.equalToSuperview().offset(1)
                make.right.equalToSuperview()
                make.size.equalTo(CGSize(width: 50, height: 50))
        }
        allButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.selectedCurrency = Currency.all
            self.sendActions(for: .valueChanged)
        }).disposed(by: disposeBag)
        
        let diamondButton = UIButton().addTo(superView: self).configure { (button) in
            button.setBackgroundImage(R.image.decorationshop_diamond(), for: .normal)
        }.layout { (make) in
            make.top.equalTo(allButton.snp.bottom).offset(1)
            make.right.equalToSuperview()
            make.size.equalTo(allButton.snp.size)
        }
        diamondButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.selectedCurrency = Currency.diamond
            self.sendActions(for: .valueChanged)
        }).disposed(by: disposeBag)
        
        let goldButton = UIButton().addTo(superView: self).configure { (button) in
            button.setBackgroundImage(R.image.decorationshop_gold(), for: .normal)
        }.layout { (make) in
            make.top.equalTo(diamondButton.snp.bottom).offset(1)
            make.right.equalToSuperview()
            make.size.equalTo(allButton.snp.size)
        }
        goldButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.selectedCurrency = Currency.gold
            self.sendActions(for: .valueChanged)
        }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
