//
//  MailAttachmentCollectionCell.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/9.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class MailAttachmentCollectionCell: UICollectionViewCell {
    
    private weak var iconView: NetImageView?
    private weak var quantityLabel: UILabel?
    private weak var receivedImageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        iconView = NetImageView().addTo(superView: contentView).layout(snapKitMaker: { (make) in
            make.edges.equalToSuperview()
        })
        
        receivedImageView = UIImageView(image: R.image.mail_attachment_received()).addTo(superView: contentView).layout(snapKitMaker: { (make) in
            make.top.right.equalToSuperview().inset(4)
        })
        
        quantityLabel = UILabel().addTo(superView: contentView).configure({ (label) in
            label.font = UIFont.size11
            label.textColor = R.color.appColor._666666()
        }).layout(snapKitMaker: { (make) in
            make.right.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().inset(4)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func bindToAttachmentEntity(_ entity: MailAttachmentEntity) {
        iconView?.imageWithUrlString(entity.iconURLString)
        quantityLabel?.text = "\(entity.qty)"
        receivedImageView?.isHidden = !entity.isRecevied
    }
}
