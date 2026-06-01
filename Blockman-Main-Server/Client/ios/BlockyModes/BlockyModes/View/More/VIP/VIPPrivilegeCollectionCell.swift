//
//  VIPPrivilegeCollectionCell.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/1.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class VIPPrivilegeCollectionCell: BMCollectionViewCell {
    
    private weak var thumbnailView: UIImageView?
    private weak var titleLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = R.color.appColor._f0d5ae()
        contentView.layer.cornerRadius = 5
        
        thumbnailView = NetImageView().addTo(superView: contentView).layout(snapKitMaker: { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.7)
            make.width.equalToSuperview().multipliedBy(0.575)
            make.height.equalToSuperview().multipliedBy(0.5)
        })
        
        titleLabel = UILabel().addTo(superView: contentView).configure {label in
            label.backgroundColor = R.color.appColor._fae7ca()
            label.font = UIFont.boldSystemFont(ofSize: 11)
            label.textColor = R.color.appColor._666666()
            label.textAlignment = .center
            label.numberOfLines = 0
            label.text = "sfiogfhshshahshd"
        }.layout { (make) in
            make.top.equalTo(self.thumbnailView!.snp.bottom).offset(5)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindToCellEntity(_ entity: ItemEntityConfigurable, indexPath: IndexPath) {
        let privilegeEntity = entity as! VIPPrivilegeEntity
        thumbnailView?.image = UIImage(named: privilegeEntity.thumbnailName)
        titleLabel?.text = privilegeEntity.title
    }
}
