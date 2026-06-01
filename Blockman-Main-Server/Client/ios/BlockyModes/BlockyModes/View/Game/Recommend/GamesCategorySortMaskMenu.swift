//
//  GamesCategorySortView.swift
//  BlockyModes
//
//  Created by KiBen on 2017/11/8.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class GamesCategorySortMaskMenu: UIControl {
    
    // element 0: 排序title element 1: 排序type
    public var selectedSortTypeTuple: (String, String) {
        get {
            return (sortTypeTitles[selectedIndex] + " ▾", sortTypes[selectedIndex])
        }
    }
    
    fileprivate var selectedIndex = 2
    fileprivate let sortTypeTitles = [NSLocalizedString("popular", comment: "人气"), NSLocalizedString("appreciate", comment: "点赞数"), NSLocalizedString("online_time", comment: "上架时间")]
    fileprivate let sortTypes = ["population", "appreciation", "onlineTime"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.black.withAlphaComponent(0.35)
        
        UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).addTo(superView: self).configure { (collectionView) in
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = R.color.appColor._e7c99e()
            collectionView.register(cellForClass: GameCategorySortMenuCollectionCell.self)
            collectionView.selectItem(at: IndexPath(row: 2, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
        }.layout { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(sortTypeTitles.count * 30 + sortTypeTitles.count)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHidden = true
    }
}

extension GamesCategorySortMaskMenu: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortTypeTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as GameCategorySortMenuCollectionCell
        cell.titleLabel?.text = sortTypeTitles[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        sendActions(for: .valueChanged)
    }
}

// MARK: GameCategorySortMenuCollectionCell
private class GameCategorySortMenuCollectionCell: UICollectionViewCell {
    
    private(set) weak var titleLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = R.color.appColor._fae7ca()
        titleLabel = UILabel().addTo(superView: contentView).configure { (label) in
            label.textColor = R.color.appColor._666666()
            label.font = UIFont.size12
        }.layout { (make) in
            make.left.equalToSuperview().offset(margin_16)
            make.centerY.equalToSuperview()
        }
    }
    
    override var isSelected: Bool {
        set {
            super.isSelected = newValue
            if isSelected {
                titleLabel?.textColor = R.color.appColor._0ab950()
            }else {
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
