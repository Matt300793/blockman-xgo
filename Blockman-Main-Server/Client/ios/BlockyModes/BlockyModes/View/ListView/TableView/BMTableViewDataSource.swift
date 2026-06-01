//
//  BMTableViewDataSource.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/5.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

protocol BMTableDataSource: UITableViewDataSource {
}

class BMTableViewDataSource: BMListDataSource {
    
    fileprivate var reuseCellType = BMTableViewCell.self
    
    required init(reuseCellType cellType: BMTableViewCell.Type) {
        reuseCellType = cellType
        super.init()
    }
}

extension BMTableViewDataSource: BMTableDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].itemsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellType.reuseIdentifier, for: indexPath) as! BMTableViewCell
        let entity = dataSource[indexPath.section].item(at: indexPath.row)
        cell.bindToCellEntity(entity, indexPath: indexPath)
        return cell
    }
}
