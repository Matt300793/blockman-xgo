//
//  DailyTaskCollectionCell.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/6.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

protocol DailyTaskCollectionCellDelegate: class {
    func dailyTaskCell(_ cell: DailyTaskCollectionCell, didClickedSignInButton cellEntity: TaskItemEntity)
}

class DailyTaskCollectionCell: BMCollectionViewCell {
    
    public weak var delegate: DailyTaskCollectionCellDelegate?
    
    private weak var rewardsLabel: UILabel?
    private weak var signInButton: UIButton?
    private var entity: TaskItemEntity!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let backgroundImageView = UIImageView(image: R.image.daily_task_gold()).addTo(superView: contentView).layout { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        
        rewardsLabel = UILabel().addTo(superView: backgroundImageView).configure({ (label) in
            label.font = UIFont.size14
            label.textColor = UIColor.white
            label.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            label.textAlignment = .center
        }).layout(snapKitMaker: { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.25)
        })
        
        signInButton = UIButton().addTo(superView: contentView).configure({ (button) in
            button.backgroundColor = R.color.appColor._0ab950()
            button.titleLabel?.font = UIFont.size14
            button.setTitleColor(UIColor.white, for: .normal)
            button.layer.cornerRadius = 5
            button.addTarget(self, action: #selector(self.didClicked), for: .touchUpInside)
        }).layout(snapKitMaker: { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.25)
        })
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindToCellEntity(_ entity: ItemEntityConfigurable, indexPath: IndexPath) {
        let taskEntity = entity as! TaskItemEntity
        self.entity = taskEntity
        rewardsLabel?.text = taskEntity.count
        
        switch taskEntity.status {
        case 0:
            signInButton?.isUserInteractionEnabled = true
            signInButton?.setTitle(R.string.localizable.receive(), for: .normal)
            signInButton?.backgroundColor = R.color.appColor._0ab950()
        default:
            signInButton?.isUserInteractionEnabled = false
            signInButton?.setTitle(R.string.localizable.has_received(), for: .normal)
            signInButton?.backgroundColor = R.color.appColor._799684()
        }
        
        switch taskEntity.type {
        case 3:
            signInButton?.setTitle(nil, for: .normal)
            signInButton?.setImage(R.image.daily_task_video(), for: .normal)
            signInButton?.isUserInteractionEnabled = false
            signInButton?.backgroundColor = R.color.appColor._799684()
        default:
            break
        }
    }
    
    public func setSignInButtonEnable(_ enable: Bool) {
        signInButton?.isUserInteractionEnabled = enable
        if enable {
            signInButton?.backgroundColor = R.color.appColor._0ab950()
        }else {
            signInButton?.backgroundColor = R.color.appColor._799684()
        }
    }
    
    @objc private func didClicked() {
        delegate?.dailyTaskCell(self, didClickedSignInButton: entity)
    }
}
