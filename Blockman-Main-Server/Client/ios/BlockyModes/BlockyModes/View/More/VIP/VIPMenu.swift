//
//  VIPMenu.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/28.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class VIPMenu: UIControl {

    public var selectedIndex: Int {
        set {
            if newValue < 0 || newValue >= images.count {
                index = 0
            }else {
                index = newValue
            }
            collectionView?.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }
        get {
            return index
        }
    }
    
    fileprivate weak var collectionView: UICollectionView?
    fileprivate let images = [R.image.vip(), R.image.vip_plus(), R.image.mvp()]
    fileprivate var index = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).addTo(superView: self).configure { (collectionView) in
            collectionView.backgroundColor = R.color.appColor._cbad83()
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(cellForClass: VIPMenuCollectionCell.self)
        }.layout(snapKitMaker: { (make) in
            make.edges.equalToSuperview()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VIPMenu: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as VIPMenuCollectionCell
        cell.imageView?.image = images[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.width - 2) / 3, height: collectionView.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.item
        sendActions(for: .valueChanged)
    }
}

private class VIPMenuCollectionCell: UICollectionViewCell {
    
    public weak var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = R.color.appColor._F5ddbb()
        
        imageView = UIImageView().addTo(superView: contentView).layout(snapKitMaker: { (make) in
            make.center.equalToSuperview()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        set {
            super.isSelected = newValue
            contentView.backgroundColor = newValue ? R.color.appColor._cbad83() : R.color.appColor._F5ddbb()
        }
        get {
            return super.isSelected
        }
    }
}
