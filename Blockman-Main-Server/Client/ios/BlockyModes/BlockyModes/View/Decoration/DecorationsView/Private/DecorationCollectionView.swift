//
//  DecorationCollectionView.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2018/1/5.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class DecorationCollectionView: UICollectionView {

    public var needReload: Bool = false
    
    private weak var holderView: LoadingHolderView?
    
    func addRefreshHeader(refreshingBlock: @escaping () -> Void) {
        let header = MJRefreshGifHeader(refreshingBlock: {
            refreshingBlock()
        })
        header?.lastUpdatedTimeLabel.isHidden = true;
        header?.stateLabel.isHidden = true
        header?.setImages([R.image.loading_1()!], for: .idle)
        header?.setImages([R.image.loading_1()!], for: .pulling)
        header?.setImages([R.image.loading_1()!, R.image.loading_2()!, R.image.loading_3()!, R.image.loading_4()!], for: .refreshing)
        mj_header = header
    }
    
    func removeRefreshHeader() {
        mj_header = nil
    }
    
    func beginRefreshing() {
        mj_header.beginRefreshing()
    }
    
    func endRefreshing() {
        mj_header.endRefreshing()
    }
    
    func showHolderView() {
        guard holderView != nil else {
            
            self.holderView = LoadingHolderView().addTo(superView: self).layout(snapKitMaker: { [unowned self] (make) in
                make.center.equalToSuperview()
                make.width.equalTo(self.width)
                make.height.equalTo(self.height)
            })
            self.holderView?.stopAnimating(holder: R.string.localizable.no_data())
            self.holderView?.isHidden = false
            return
        }
        bringSubview(toFront: holderView!)
        holderView?.isHidden = false
    }
    
    func dismissHolderView() {
        holderView?.isHidden = true
    }
    
    override func updateConstraints() {
        if let holderView = self.holderView {
            holderView.snp.updateConstraints { (make) in
                make.width.equalTo(self.width)
                make.height.equalTo(self.height)
            }
        }
        
        super.updateConstraints()
    }
}
