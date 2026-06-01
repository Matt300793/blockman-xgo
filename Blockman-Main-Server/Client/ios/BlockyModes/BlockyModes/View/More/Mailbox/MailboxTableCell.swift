//
//  MailboxTableCell.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/9.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class MailboxTableCell: BMTableViewCell {

    private weak var mailIconView: UIImageView?
    private weak var mailTitleLabel: UILabel?
    private weak var mailDateLabel: UILabel?
    private weak var mailAttachmentLabel: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = R.color.appColor._fae7ca()
        UIView().addTo(superView: contentView).configure { (view) in
            view.backgroundColor = R.color.appColor._e7c99e()
        }.layout { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        mailIconView = UIImageView().addTo(superView: contentView).layout { (make) in
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(margin_12)
        }
        
        mailTitleLabel = UILabel().addTo(superView: contentView).configure({ (label) in
            label.textColor = R.color.appColor._333333()
            label.font = UIFont.size14
        }).layout(snapKitMaker: { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(mailIconView!.snp.right).offset(5)
        })
        
        mailAttachmentLabel = UILabel().addTo(superView: contentView).configure({ (label) in
            label.font = UIFont.size11
            label.textColor = R.color.appColor._0ab950()
            label.text = "还未打开附件"
        }).layout(snapKitMaker: { (make) in
            make.left.equalTo(mailIconView!.snp.right).offset(5)
            make.top.equalTo(mailTitleLabel!.snp.bottom).offset(5)
        })
        
        mailDateLabel = UILabel().addTo(superView: contentView).configure({ (label) in
            label.textColor = R.color.appColor._666666()
            label.font = UIFont.size12
        }).layout(snapKitMaker: { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(margin_16)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindToCellEntity(_ entity: ItemEntityConfigurable, indexPath: IndexPath) {
        let mailEntity = entity as! MailboxEntity
        mailTitleLabel?.text = mailEntity.title
        mailDateLabel?.text = mailEntity.sendDate
        switch mailEntity.status {
        case .send:
            mailIconView?.image = R.image.mail_unread()
            guard mailEntity.attachments.count == 0 else {
                mailAttachmentLabel?.isHidden = false
                mailTitleLabel!.snp.updateConstraints({ (make) in
                    make.centerY.equalToSuperview().offset(-10)
                })
                return
            }
            mailAttachmentLabel?.isHidden = true
            mailTitleLabel!.snp.updateConstraints({ (make) in
                make.centerY.equalToSuperview()
            })
        default:
            mailIconView?.image = R.image.mail_read()
            mailAttachmentLabel?.isHidden = true
            mailTitleLabel!.snp.updateConstraints({ (make) in
                make.centerY.equalToSuperview()
            })
        }
    }
}
