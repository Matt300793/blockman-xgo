//
//  BMListDataSource.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/6.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

class BMListDataSource: NSObject {
    
    private(set) var dataSource: [SectionObject] = []
    
    public func set(_ objects: [SectionObject]) {
        dataSource.removeAll()
        dataSource = objects
    }
    
    public func replace(object: SectionObject, at index: Int) {
        guard index < dataSource.count else { return }
        dataSource[index] = object
    }
    
    public func sectionObject(for section: Int) -> SectionObject {
        if dataSource.count == 0 || section >= dataSource.count {
            return SectionObject(items: [])
        }
        return dataSource[section]
    }
    
    public func insert(object: SectionObject, at index: Int) {
        guard index < dataSource.count else { return }
        dataSource.insert(object, at: index)
    }
    
    public func append(object: SectionObject) {
        dataSource.append(object)
    }
    
    public func remove(at index: Int) {
        guard index < dataSource.count else { return }
        dataSource.remove(at: index)
    }
    
    public func removeAll() {
        dataSource.removeAll()
    }
}
