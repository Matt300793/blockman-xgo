//
//  RefreshEnable.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/6.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

protocol RefreshEnable {
    func headerRefreshEnable(callBack: (() -> Void)?)
    func footerRefreshEnable(callBack: (() -> Void)?)
    
    func headerDidRefresh()
    func footerDidRefresh()
}

extension RefreshEnable where Self: UIScrollView {
    func headerRefreshEnable(callBack: (() -> Void)? = nil) {
        let header = MJRefreshGifHeader.init(refreshingBlock: { [unowned self] in
            guard let callBack = callBack else {self.headerDidRefresh(); return}
            callBack()
        })
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.stateLabel.isHidden = true
        header?.setImages([R.image.loading_1()!], for: .idle)
        header?.setImages([R.image.loading_1()!], for: .pulling)
        header?.setImages([R.image.loading_1()!, R.image.loading_2()!, R.image.loading_3()!, R.image.loading_4()!], for: .refreshing)
        self.mj_header = header
    }
    
    func footerRefreshEnable(callBack: (() -> Void)? = nil) {
        let footer = MJRefreshBackGifFooter.init(refreshingBlock: { [unowned self] in
            guard let callBack = callBack else {self.footerDidRefresh(); return}
            callBack()
        })
        footer?.stateLabel.isHidden = true
        footer?.setImages([R.image.loading_1()!], for: .idle)
        footer?.setImages([R.image.loading_1()!], for: .pulling)
        footer?.setImages([R.image.loading_1()!, R.image.loading_2()!, R.image.loading_3()!, R.image.loading_4()!], for: .refreshing)
        self.mj_footer = footer
    }
    
    func triggleRefreshing() {
        mj_header.beginRefreshing()
    }
    
    func endRefreshing() {
        if mj_header != nil {
            mj_header.endRefreshing()
        }
        
        if mj_footer != nil {
            mj_footer.endRefreshing()
        }
    }
    
}

extension UITableView: RefreshEnable {
    func headerDidRefresh() { }
    
    func footerDidRefresh() { }
}

extension UICollectionView: RefreshEnable {
    func headerDidRefresh() { }
    
    func footerDidRefresh() { }
}
