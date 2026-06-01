//
//  UserPortraitView.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/23.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class UserPortraitView: UIView {

    private let netImageV: NetImageView
    
    override init(frame: CGRect) {
        netImageV = NetImageView()
        super.init(frame: frame)
        
        let portraitBorder =  UIImageView(image: R.image.common_portrait_border())
        self.addSubview(portraitBorder)
        portraitBorder.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(netImageV)
        netImageV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(4)
        }
    }
    
    func portraitWithUrlString(_ urlString: String?, placeHolder: UIImage? = nil) {
        netImageV.imageWithUrlString(urlString, placeHolder: placeHolder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
