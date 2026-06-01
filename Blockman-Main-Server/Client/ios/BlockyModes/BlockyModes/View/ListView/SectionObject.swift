//
//  SectionEntity.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/5.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class SectionObject {
    
    private(set) var items = [ItemEntityConfigurable]()
    
    required init(items: [ItemEntityConfigurable]) {
        self.items = items
    }
    
    public func reset(items: [ItemEntityConfigurable]) {
        self.items = items
    }
    
    public func itemsCount() -> Int {
        return items.count
    }
    
    public func item(at index: Int) -> ItemEntityConfigurable {
        return items[index]
    }
    
    public func insert(items: [ItemEntityConfigurable], at index: Int) {
        guard index < self.items.count else {return}
        self.items.insert(contentsOf: items, at: index)
    }
    
    public func append(items: [ItemEntityConfigurable]) {
        self.items.append(contentsOf: items)
    }
}
