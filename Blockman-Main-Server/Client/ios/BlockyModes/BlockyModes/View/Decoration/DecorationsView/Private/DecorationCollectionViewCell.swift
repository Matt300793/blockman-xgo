//
//  DecorationCollectionViewCell.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/3.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class DecorationCollectionViewCell: UICollectionViewCell {

    public var reusableView: DecorationReusableView?
    
    private var reusableViewClass: DecorationReusableView.Type?
    
    public func setReusableViewClass(_ aClass: DecorationReusableView.Type) {
        
        if reusableViewClass == nil || reusableViewClass != aClass {
            contentView.subviews.forEach({ $0.removeFromSuperview() })
            
            reusableViewClass = aClass
            reusableView = reusableViewClass!.init().addTo(superView: contentView).layout(snapKitMaker: { (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    
    override var isSelected: Bool {
        set {
            super.isSelected = newValue

            reusableView?.set(selected: newValue)
        }

        get {
            return super.isSelected
        }
    }
}
