//
//  LoadingHolderEnable.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/7.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

protocol LoadingHolderEnable {
    
}

extension LoadingHolderEnable where Self: UIScrollView {
    func showLoadingHolder() {
        for subView in self.subviews.reversed() {
            if subView is LoadingHolderView {
                subView.isHidden = false
                return
            }
        }
        
        LoadingHolderView().addTo(superView: self).configure { (holderView) in
            self.bringSubview(toFront: holderView)
        }.layout { (make) in
            make.left.top.equalToSuperview()
            make.size.equalToSuperview()
            layoutIfNeeded()
        }
    }
    
    func inNoData(holderText: String = R.string.localizable.no_data()) {
        let holderView = self.subviews.reversed().filter {
            $0 is LoadingHolderView
        }.first
        
        guard let holder = holderView as? LoadingHolderView else {
            LoadingHolderView().addTo(superView: self).configure { (holderView) in
                self.bringSubview(toFront: holderView)
                holderView.withNoData(holder: holderText)
            }.layout { (make) in
                make.left.top.equalToSuperview()
                make.size.equalToSuperview()
                layoutIfNeeded()
            }
            return
        }
        holder.isHidden = false
        holder.withNoData(holder: holderText)
        self.bringSubview(toFront: holder)
    }
    
    func dismissLoadingHolder() {
        let holderView = self.subviews.reversed().filter {
            $0 is LoadingHolderView
        }.first
        holderView?.isHidden = true
    }
}
