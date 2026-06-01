//
//  GamesSegmentControl.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/3.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift

class GamesSegmentControl: UIControl {
    
    public var selectedIndex: Int = 0 {
        willSet {
            itemButtons.forEach { $0.isSelected = false }
            if newValue >= 0 && newValue < itemButtons.count {
                itemButtons[newValue].isSelected = true
                decorateImageView?.snp.remakeConstraints({ (make) in
                    make.bottom.equalToSuperview()
                    make.center.equalTo(itemButtons[newValue].snp.center)
                })
            }
        }
    }
    
    private let disposeBag = DisposeBag()
    private var itemButtons: [UIButton] = []
    private weak var seperatorLine: UIView?
    private var recommendButton: UIButton?
    private var categoryButton: UIButton?
    private var decorateImageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = R.color.appColor._00925a()
        
        let buttonConfig = { (button: UIButton) in
            button.titleLabel?.font = UIFont.size15
            button.setImage(UIImage(), for: .normal)
            button.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .normal)
            button.setTitleColor(UIColor.white, for: .selected)
        }
        
        seperatorLine = UIView().addTo(superView: self).configure({ (line) in
            line.backgroundColor = R.color.appColor._007c4d()
        })
        
        let recommendButton = UIButton().addTo(superView: self).configure(buttonConfig).configure { (button) in
            button.setTitle(NSLocalizedString("recommend", comment: "推荐"), for: .normal)
        }
        recommendButton.rx.tap.subscribe(onNext: {[unowned self] in
            self.selectedIndex = 0
            self.sendActions(for: .valueChanged)
        }).disposed(by: disposeBag)
        itemButtons.append(recommendButton)
        
        let categoryButton = UIButton().addTo(superView: self).configure(buttonConfig).configure { (button) in
            button.setTitle(NSLocalizedString("category", comment: "分类"), for: .normal)
        }
        categoryButton.rx.tap.subscribe(onNext: {[unowned self] in
            self.selectedIndex = 1
            self.sendActions(for: .valueChanged)
        }).disposed(by: disposeBag)
        itemButtons.append(categoryButton)
        
        decorateImageView = UIImageView(image: R.image.game_tab_selected()).addTo(superView: self).configure { [unowned self] (imageView) in
            self.sendSubview(toBack: imageView)
        }.layout(snapKitMaker: { (make) in
            make.bottom.equalToSuperview()
            make.center.equalTo(recommendButton.snp.center)
        })
    }
    
    override func updateConstraints() {
        
        seperatorLine?.layout(snapKitMaker: { (make) in
            make.size.equalTo(CGSize(width: 1, height: 15))
            make.centerX.centerY.equalToSuperview()
        })
        
        itemButtons[0].layout(snapKitMaker: { [unowned self] (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(self.seperatorLine!)
        })
        
        itemButtons[1].layout(snapKitMaker: { [unowned self] (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(self.seperatorLine!.snp.right)
        })
        super.updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
