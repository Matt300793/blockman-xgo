//
//  BMCollectionViewDataSource.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/6.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

protocol BMCollectionDataSource: UICollectionViewDataSource {
}

class BMCollectionViewDataSource: BMListDataSource {
    fileprivate var reuseCellType = BMCollectionViewCell.self
    
    required init(reuseCellType cellType: BMCollectionViewCell.Type) {
        reuseCellType = cellType
        super.init()
    }
}

extension BMCollectionViewDataSource: BMCollectionDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].itemsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCellType.reuseIdentifier, for: indexPath) as! BMCollectionViewCell
        let entity = dataSource[indexPath.section].item(at: indexPath.row)
        cell.bindToCellEntity(entity, indexPath: indexPath)
        return cell
    }
}
