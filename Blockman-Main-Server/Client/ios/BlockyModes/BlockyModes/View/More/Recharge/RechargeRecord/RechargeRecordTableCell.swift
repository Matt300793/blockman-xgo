//
//  RechargeRecordTableCell.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/17.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class RechargeRecordTableCell: BMTableViewCell {

    private weak var titleLabel: UILabel?
    private weak var sourceFromLabel: UILabel?
    private weak var createdTimeLabel: UILabel?
    private weak var statusLabel: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = R.color.appColor._fae7ca()
        contentView.backgroundColor = R.color.appColor._fae7ca()
        selectionStyle = .none
        
        UIView().addTo(superView: contentView).configure { (seperatorLine) in
            seperatorLine.backgroundColor = R.color.appColor._e7c99e()
        }.layout { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        titleLabel = UILabel().addTo(superView: contentView).configure({ (label) in
            label.textColor = R.color.appColor._333333()
            label.font = UIFont.size15
        }).layout(snapKitMaker: { (make) in
            make.left.top.equalToSuperview().offset(margin_16)
        })
        
        sourceFromLabel = UILabel().addTo(superView: contentView).configure({ (label) in
            label.textColor = R.color.appColor._666666()
            label.font = UIFont.size12
        }).layout(snapKitMaker: { [unowned self] (make) in
            make.left.equalToSuperview().offset(margin_16)
            make.top.equalTo(self.titleLabel!.snp.bottom).offset(margin_10)
        })
        
        createdTimeLabel = UILabel().addTo(superView: contentView).configure({ (label) in
            label.textColor = R.color.appColor._666666()
            label.font = UIFont.size12
        }).layout(snapKitMaker: { [unowned self] (make) in
            make.left.equalTo(self.sourceFromLabel!.snp.right).offset(margin_12)
            make.centerY.equalTo(self.sourceFromLabel!)
        })
        
        statusLabel = UILabel().addTo(superView: contentView).configure({ (label) in
            label.textColor = R.color.appColor._0ab950()
            label.font = UIFont.size12
        }).layout(snapKitMaker: {(make) in
            make.right.equalToSuperview().offset(-30)
            make.centerY.equalToSuperview()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindToCellEntity(_ entity: ItemEntityConfigurable, indexPath: IndexPath) {
        let recordEntity = entity as! RechargeRecordEntity
        titleLabel?.text = recordEntity.title
        sourceFromLabel?.text = recordEntity.sourceFrom
        createdTimeLabel?.text = recordEntity.createdTime
        statusLabel?.text = recordEntity.status
    }
}
