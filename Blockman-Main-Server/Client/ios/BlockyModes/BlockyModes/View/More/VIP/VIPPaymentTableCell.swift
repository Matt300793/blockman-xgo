//
//  VIPPaymentTableCell.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2018/3/1.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

protocol VIPPaymentTableCellDelegate: class {
    func vipPaymentCellDidTap(entity: VIPEntity)
}

class VIPPaymentTableCell: BMTableViewCell {

    public weak var delegate: VIPPaymentTableCellDelegate?
    
    private weak var nameLabel: UILabel?
    private weak var priceLabel: UILabel?
    private weak var payButton: UIButton?
    private var entity: VIPEntity!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = R.color.appColor._cbad83()
        
        let containView = UIView().addTo(superView: contentView).configure { (view) in
            view.backgroundColor = R.color.appColor._f0d5ae()
        }.layout { (make) in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(5)
        }
        
        nameLabel = UILabel().addTo(superView: containView).configure({ (label) in
            label.font = UIFont.size14
            label.textColor = R.color.appColor._333333()
        }).layout(snapKitMaker: { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        })
        
        payButton = UIButton().addTo(superView: containView).configure({ (button) in
            button.backgroundColor = R.color.appColor._d52626()
            button.layer.cornerRadius = 5
            button.titleLabel?.font = UIFont.size12
            button.addTarget(self, action: #selector(self.payButtonDidTouched), for: .touchUpInside)
        }).layout(snapKitMaker: { (make) in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 30))
        })

        priceLabel = UILabel().addTo(superView: containView).layout(snapKitMaker: { (make) in
            make.right.equalTo(payButton!.snp.left).inset(-10)
            make.centerY.equalToSuperview()
        }).configure({ (label) in
            label.font = UIFont.size13
            label.textColor = R.color.appColor._333333()
            label.textAlignment = .right
        })
        
        UIImageView(image: R.image.common_diamond()).addTo(superView: containView).layout { (make) in
            make.right.equalTo(priceLabel!.snp.left).offset(-5)
            make.centerY.equalTo(priceLabel!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func payButtonDidTouched() {
        delegate?.vipPaymentCellDidTap(entity: entity)
    }
    
    override func bindToCellEntity(_ entity: ItemEntityConfigurable, indexPath: IndexPath) {
        let vipEntity = entity as! VIPEntity
        self.entity = vipEntity
        nameLabel?.text = vipEntity.productName
        priceLabel?.text = vipEntity.price
        payButton?.setTitle(vipEntity.payTypeText, for: .normal)
    }

}
