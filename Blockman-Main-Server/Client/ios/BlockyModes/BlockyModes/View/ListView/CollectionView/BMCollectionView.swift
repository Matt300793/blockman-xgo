//
//  BMCollectionView.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/6.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

protocol BMCollectionViewDelegate: UICollectionViewDelegateFlowLayout {
    func collectionViewDidRefresh(_ collectionView: BMCollectionView)
    func collectionViewDidLoadMore(_ collectionView: BMCollectionView)
}

extension BMCollectionViewDelegate {
    func collectionViewDidRefresh(_ collectionView: BMCollectionView) { }
    func collectionViewDidLoadMore(_ collectionView: BMCollectionView) { }
}

class BMCollectionView: UICollectionView, LoadingHolderEnable {

    public weak var bmDelegate: BMCollectionViewDelegate? = nil {
        didSet {
            delegate = bmDelegate
        }
    }
    
    public weak var bmDataSource: BMCollectionDataSource? = nil {
        didSet {
            dataSource = bmDataSource
        }
    }
    
    override func headerDidRefresh() {
        bmDelegate?.collectionViewDidRefresh(self)
    }
    
    override func footerDidRefresh() {
        bmDelegate?.collectionViewDidLoadMore(self)
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        backgroundColor = R.color.appColor._e7c99e()
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
