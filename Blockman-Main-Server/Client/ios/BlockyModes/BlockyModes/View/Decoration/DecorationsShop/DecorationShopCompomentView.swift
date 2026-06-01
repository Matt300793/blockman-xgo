//
//  DecorationShopCompomentView.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/10.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class DecorationShopCompomentView: DecorationReusableView {

    private weak var thumbnailImageView: NetImageView!
    private weak var isNewLabel: UILabel!
    private weak var limitedLabel: UILabel!
    private weak var limitedImageView: UIImageView!
    private weak var priceView: UIButton!
    private weak var borderShapeLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = R.color.appColor._fae7ca()
        
        let borderLayer = CAShapeLayer()
        borderLayer.lineWidth = 2
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = R.color.appColor._70c07a().cgColor
        layer.addSublayer(borderLayer)
        borderShapeLayer = borderLayer
        
        limitedLabel = UILabel().addTo(superView: self).configure { (label) in
            label.font = UIFont.size10
            label.backgroundColor = R.color.appColor._e55642()
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.text = "Limited"
            }.layout { (make) in
                make.left.top.equalToSuperview()
                make.height.equalTo(18)
                make.width.equalToSuperview().multipliedBy(0.55)
        }
        
        isNewLabel = UILabel().addTo(superView: self).configure { (label) in
            label.font = UIFont.size10
            label.textColor = R.color.appColor._d74242()
            label.textAlignment = .right
            label.text = "NEW!"
            label.isHidden = true
            }.layout { (make) in
                make.top.right.equalToSuperview().inset(5)
        }
        
        thumbnailImageView = NetImageView().addTo(superView: self).layout { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 64, height: 64))
            }.configure { (imageView) in
                imageView.image = R.image.common_default_userimage()
        }
        
        limitedImageView = UIImageView().addTo(superView: thumbnailImageView)
            .configure { (imageView) in
                imageView.image = R.image.decorationshop_limit()
            }.layout { (make) in
                make.bottom.right.equalToSuperview()
        }
        
        priceView = UIButton().addTo(superView: self).configure({ (button) in
            button.isUserInteractionEnabled = false
            button.titleLabel?.font = UIFont.size12
            button.setTitleColor(R.color.appColor._555555(), for: .normal)
        }).layout(snapKitMaker: { (make) in
            make.top.equalTo(self.thumbnailImageView.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        borderShapeLayer.path = UIBezierPath(rect: bounds.insetBy(dx: 1.5, dy: 1.5)).cgPath
    }
    
    override func configure(withContent content: Any?) {
        guard let entity = content as? DecorationShopEntity else { return }
        thumbnailImageView.imageWithUrlString(entity.thumbnailURLString)
        isNewLabel.isHidden = !entity.isNew
        limitedLabel.isHidden = !entity.isLimited
        limitedImageView.isHidden = !entity.isLimited
        if entity.hasPurchased {
            priceView.setTitle(R.string.localizable.decoration_has_purchased(), for: .normal)
            priceView.setImage(nil, for: .normal)
        }else {
            switch entity.priceType {
            case DecorationShopEntity.PriceType.diamond:
                priceView.setImage(R.image.common_diamond(), for: .normal)
            case DecorationShopEntity.PriceType.gold:
                priceView.setImage(R.image.common_gold(), for: .normal)
            }
            priceView.setTitle(entity.price, for: .normal)
        }
    }
    
    override func set(selected: Bool) {
        borderShapeLayer.isHidden = !selected
    }

}
