//
//  DecorationMenuView.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/3.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

private class DecorationMenuCollectionCell: UICollectionViewCell {
    
    public weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView().addTo(superView: self).layout { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        set {
            super.isSelected = newValue
            imageView.isHighlighted = isSelected
        }
        
        get {
            return super.isSelected
        }
    }
}

class DecorationMenu: UIControl {

    var selectedIndex: Int {
        set {
            collectionView.indexPathsForSelectedItems?.forEach({
                collectionView.deselectItem(at: $0, animated: false)
            }) 
            
            if newValue != NSNotFound {
                collectionView.selectItem(at: IndexPath(item: newValue, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            }
        }
        
        get {
            return collectionView.indexPathsForSelectedItems?.count == 0 ? NSNotFound : collectionView.indexPathsForSelectedItems!.first!.item
        }
    }
    
    private weak var collectionView: UICollectionView!
    fileprivate let images = ["decoration_clothes", "decoration_hair", "decoration_accessory", "decoration_emotion", "decoration_action", "decoration_skin"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = R.color.appColor._e7c99e()
        
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 50, height: 50)
        flowLayout.minimumLineSpacing = 1
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).addTo(superView: self).configure { (collectionView) in
            collectionView.backgroundColor = R.color.appColor._e7c99e()
            collectionView.register(DecorationMenuCollectionCell.self, forCellWithReuseIdentifier: String.init(describing: DecorationMenuCollectionCell.self))
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.index
            }.layout { (make) in
                make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DecorationMenu:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String.init(describing: DecorationMenuCollectionCell.self), for: indexPath) as! DecorationMenuCollectionCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let menuCell = cell as! DecorationMenuCollectionCell
        menuCell.imageView.image = UIImage(named: images[indexPath.row])
        menuCell.imageView.highlightedImage = UIImage(named: images[indexPath.row] + "_selected")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sendActions(for: .valueChanged)
    }
}
