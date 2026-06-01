//
//  GamesCategoryMenuView.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/11/5.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class GamesCategoryMenu: UIControl {
    
    public var selectedCategory: Int {
        get {
            return category
        }
    }
    
    fileprivate var category = 0
    fileprivate let categoryTitles = [NSLocalizedString("category_all", comment: "全部"), NSLocalizedString("category_pvp", comment: "PVP"), NSLocalizedString("category_manage", comment: "经营"), NSLocalizedString("category_adventure", comment: "冒险"), NSLocalizedString("category_gun", comment: "枪战")]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = R.color.appColor._fae7ca()
        
        UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).addTo(superView: self).configure { (collectionView) in
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = UIColor.clear
            collectionView.showsHorizontalScrollIndicator = false
            (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).scrollDirection = .horizontal
            collectionView.register(cellForClass: GameCategoryMenuCollectionCell.self)
            collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
        }.layout { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension GamesCategoryMenu: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as GameCategoryMenuCollectionCell
        cell.titleLabel?.text = categoryTitles[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 45, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 10, 8, 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        category = indexPath.item
        sendActions(for: .valueChanged)
    }
}

// MARK: GameCategoryMenuCollectionCell
private class GameCategoryMenuCollectionCell: UICollectionViewCell {
    
    private(set) weak var titleLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel().addTo(superView: contentView).configure { (label) in
            label.backgroundColor = UIColor.white
            label.textColor = R.color.appColor._666666()
            label.font = UIFont.size12
            label.textAlignment = .center
            }.layout { (make) in
                make.edges.equalToSuperview()
        }
    }
    
    override var isSelected: Bool {
        set {
            super.isSelected = newValue
            if isSelected {
                titleLabel?.backgroundColor = R.color.appColor._0ab950()
                titleLabel?.textColor = UIColor.white
            }else {
                titleLabel?.backgroundColor = UIColor.white
                titleLabel?.textColor = R.color.appColor._666666()
            }
        }
        
        get {
            return super.isSelected
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
