//
//  DecorationShoppingCartTableCell.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/15.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class DecorationShoppingCartTableCell: UITableViewCell {

    private weak var thumbnailImageView: NetImageView?
    private weak var nameLabel: UILabel?
    private weak var limitedLabel: UILabel?
    private weak var priceView: UIButton?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        let containView = UIView().addTo(superView: contentView).configure { (view) in
            view.backgroundColor = R.color.appColor._fae7ca()
        }.layout { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-1)
        }
        
        let thumbnailImageView = NetImageView().addTo(superView: containView).layout { (make) in
            make.size.equalTo(CGSize(width: 64, height: 64))
            make.left.equalToSuperview().offset(margin_12)
            make.centerY.equalToSuperview()
        }
        self.thumbnailImageView = thumbnailImageView
        
        let nameLabel = UILabel().addTo(superView: containView).configure { (label) in
            label.textColor = R.color.appColor._333333()
            label.font = UIFont.size14
        }.layout { (make) in
            make.left.equalTo(thumbnailImageView.snp.right).offset(margin_14)
            make.centerY.equalToSuperview().offset(-margin_16)
        }
        self.nameLabel = nameLabel
        
        let limitLabel = UILabel().addTo(superView: containView).configure { (label) in
            label.textColor = R.color.appColor._d74242()
            label.font = UIFont.size11
            }.layout { (make) in
                make.left.equalTo(nameLabel)
                make.top.equalTo(nameLabel.snp.bottom).offset(margin_10)
        }
        self.limitedLabel = limitLabel
        
        let priceView = UIButton().addTo(superView: containView).configure { (button) in
            button.titleLabel?.font = UIFont.size15
            button.setTitleColor(R.color.appColor._555555(), for: .normal)
            button.contentHorizontalAlignment = .right
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        }.layout { (make) in
            make.right.equalToSuperview().offset(-margin_12)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(85)
        }
        self.priceView = priceView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(shopEntity entity: DecorationShopEntity) {
        thumbnailImageView?.imageWithUrlString(entity.thumbnailURLString)
        nameLabel?.text = entity.name
        limitedLabel?.text = entity.remainQuantityString
        
        if entity.hasPurchased {
            priceView?.setTitle(NSLocalizedString("decoration_has_purchased", comment: "已拥有"), for: .normal)
            return
        }
        
        switch entity.priceType {
        case DecorationShopEntity.PriceType.diamond:
            priceView?.setImage(R.image.common_diamond(), for: .normal)
            priceView?.setTitle(entity.price, for: .normal)
        default:
            priceView?.setImage(R.image.common_gold(), for: .normal)
            priceView?.setTitle(entity.price, for: .normal)
        }
    }
}
