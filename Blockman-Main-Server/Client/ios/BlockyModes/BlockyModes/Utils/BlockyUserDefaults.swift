//
//  BlockyUserDefaults.swift
//  BlockyModes
//
//  Created by KiBen on 2017/12/28.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation

extension BlockyUserDefaults {
    static let appUpdateTimeintervalKey = "appUpdateTimeintervalKey"
    static let unverifyTransactionKey = "unverifyTransactionDefaultsKey"
    static let accountPropertyKey = "accountPropertyKey"
    static let enterGameTimeIntervalKey = "enterGameTimeIntervalKey"
    static let dailyWatchVideoAdsTimeIntervalKey = "dailyWatchVideoAdsTimeIntervalKey"
}

struct BlockyUserDefaults {
    static private let userDefaults = UserDefaults.standard
    
    public static func storeData(_ data: Data?, forKey key: String) {
        userDefaults.set(data, forKey: key)
        userDefaults.synchronize()
    }
    
    public static func data(forKey key: String) -> Data? {
        return userDefaults.data(forKey: key)
    }
    
    public static func storeTimeInterval(_ timeInterval: TimeInterval, forKey key: String) {
        userDefaults.set(timeInterval, forKey: key)
        userDefaults.synchronize()
    }
    
    public static func timeInterval(forKey key: String) -> TimeInterval {
        return userDefaults.double(forKey: key)
    }
    
    public static func storeDate(_ date: Date?, forKey key: String) {
        userDefaults.set(date, forKey: key)
        userDefaults.synchronize()
    }
    
    public static func date(forKey key: String) -> Date? {
        return userDefaults.object(forKey: key) as? Date
    }
    
    public static func storeInteger(_ integer: Int, forKey key: String) {
        userDefaults.set(integer, forKey: key)
        userDefaults.synchronize()
    }
    
    public static func integer(forKey key: String) -> Int {
        return userDefaults.integer(forKey: key)
    }
    
    public static func removeValue(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
