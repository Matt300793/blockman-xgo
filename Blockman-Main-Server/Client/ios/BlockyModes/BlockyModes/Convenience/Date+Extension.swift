//
//  Date+Extension.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/28.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation

extension Date {
    
    func convertToString(formatter: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        return dateFormatter.string(from: self)
    }
    
    // 判断是否是第二天
    // 只根据天数判断，不根据时间间隔是否够24小时
    func isNextDay(from previous: Date) -> Bool {
        let calendar = Calendar.current
        
        var component = calendar.dateComponents([.year, .month, .day], from: previous)
        component.day! += 1 // 第二天
        let nextDayTimeInterval = calendar.date(from: component)?.timeIntervalSince1970
        
        component.day! += 1 // 第三天
        let twoDaysLaterTimeInterval = calendar.date(from: component)?.timeIntervalSince1970
        
        guard nextDayTimeInterval != nil, twoDaysLaterTimeInterval != nil else { return false }
        
        let currentTimeInterval = self.timeIntervalSince1970
        return currentTimeInterval >= nextDayTimeInterval! && currentTimeInterval < twoDaysLaterTimeInterval!
    }
}
