//
//  RechargeCollectionViewCell.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/16.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class RechargeCollectionViewCell: UICollectionViewCell {
    
    private weak var thumbnailImageView: UIImageView?
    private weak var nameLabel: UILabel?
    private weak var priceLabel: UILabel?
    private weak var giftLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = R.color.appColor._fae7ca()
        
        thumbnailImageView = UIImageView().addTo(superView: contentView).configure({ (imageView) in
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
        }).layout(snapKitMaker: { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.size.equalToSuperview().multipliedBy(0.5)
        })
        
        priceLabel = UILabel().addTo(superView: contentView).configure({ (label) in
            label.backgroundColor = R.color.appColor._ead5b6()
            label.textAlignment = .center
        }).layout(snapKitMaker: { (make) in
            make.left.right.bottom.equalToSuperview().inset(8)
            make.height.equalTo(36)
        })
        
        nameLabel = UILabel().addTo(superView: contentView).layout(snapKitMaker: { (make) in
            make.bottom.equalTo(self.priceLabel!.snp.top).offset(-margin_10)
            make.centerX.equalToSuperview()
        })
        
        giftLabel = UILabel().addTo(superView: contentView).configure({ (label) in
            label.backgroundColor = R.color.appColor._e60012()
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.font = UIFont.size14
        }).layout(snapKitMaker: { (make) in
            make.top.right.equalToSuperview()
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(70)
        })
    }
    
    public func configure(rechargeEntity entity: RechargeProductEntity) {
        thumbnailImageView?.image = UIImage(named: entity.thumbnail)
        let nameAttributeString = NSMutableAttributedString(string: entity.name, attributes: [NSForegroundColorAttributeName : R.color.appColor._0193b7(), NSFontAttributeName : UIFont.systemFont(ofSize: 20)])
        nameAttributeString.append(NSAttributedString(string: NSLocalizedString("recharge_diamond", comment: "魔方"), attributes: [NSForegroundColorAttributeName : R.color.appColor._333333(), NSFontAttributeName : UIFont.size11]))
        nameLabel?.attributedText = nameAttributeString
        
        let priceAttributedString = NSMutableAttributedString(string: NSLocalizedString("recharge_price", comment: "价格: "), attributes: [NSForegroundColorAttributeName : R.color.appColor._666666(), NSFontAttributeName : UIFont.size12])
        priceAttributedString.append(NSAttributedString(string: entity.price, attributes: [NSForegroundColorAttributeName : R.color.appColor._666666(), NSFontAttributeName : UIFont.size12]))
        priceLabel?.attributedText = priceAttributedString
        
        if entity.gift != "0" {
            giftLabel?.isHidden = false
            giftLabel?.text = String(format: NSLocalizedString("recharge_gift_more", comment: "赠送%s"), entity.gift)
        }else {
            giftLabel?.isHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
