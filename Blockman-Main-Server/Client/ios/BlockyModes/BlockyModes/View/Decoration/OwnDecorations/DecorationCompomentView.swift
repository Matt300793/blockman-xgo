//
//  DecorationCompomentView.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2018/1/7.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class DecorationCompomentView: DecorationReusableView {

    private weak var thumbnailImageView: NetImageView!
    private weak var expireLabel: UILabel!
    private weak var selectedImageView: UIImageView!
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
        
        //        UILabel().addTo(superView: self).configure { (label) in
        //            label.font = UIFont.size10
        //            label.backgroundColor = R.color.appColor._e55642()
        //            label.textColor = UIColor.white
        //            label.textAlignment = .center
        //            label.text = "Limited"
        //            }.layout { (make) in
        //                make.left.top.equalToSuperview()
        //                make.height.equalTo(18)
        //                make.width.equalToSuperview().multipliedBy(0.55)
        //        }
        
        selectedImageView =
            UIImageView()
                .addTo(superView: self)
                .configure { (imageView) in
                    imageView.image = R.image.decoration_selected()
                    imageView.isHidden = true
                }
                .layout { (make) in
                    make.top.right.equalToSuperview().inset(5)
        }
        
        selectedImageView = UIImageView().addTo(superView: self)
            .configure { (imageView) in
                imageView.image = R.image.decoration_selected()
                imageView.isHidden = true
            }.layout { (make) in
                make.top.right.equalToSuperview().inset(5)
        }
        
        thumbnailImageView = NetImageView().addTo(superView: self).layout { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 64, height: 64))
            }.configure { (imageView) in
                imageView.image = R.image.common_default_userimage()
        }
        
        expireLabel = UILabel().addTo(superView: self).configure { (label) in
            label.font = UIFont.size10
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.backgroundColor = R.color.appColor._e55642()
            label.isHidden = true
            }.layout { (make) in
                make.left.bottom.right.equalToSuperview()
                make.height.equalTo(14)
        }
    }
    
    override func layoutSubviews() {
         super.layoutSubviews()
        
        borderShapeLayer.path = UIBezierPath(rect: bounds.insetBy(dx: 1.5, dy: 1.5)).cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func configure(withContent content: Any?) {
        guard let entity = content as? DecorationEntity else { return }
        thumbnailImageView.imageWithUrlString(entity.thumbnailURLString)
        switch entity.validity {
        case DecorationEntity.Validity.forever:
            expireLabel.isHidden = true
        case DecorationEntity.Validity.expired:
            expireLabel.isHidden = false
            expireLabel.backgroundColor = R.color.appColor._a7a7a7()
            expireLabel.text = entity.expireDayString
        default:
            expireLabel.isHidden = false
            expireLabel.backgroundColor = R.color.appColor._e55642()
            expireLabel.text = entity.expireDayString
        }
    }
    
    override func set(selected: Bool) {
        selectedImageView.isHidden = !selected
        borderShapeLayer.isHidden = !selected
    }
}
