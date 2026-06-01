//
//  AccountStatusManager.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/27.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift

let UserDefaultsAccountStatusKey = "UserDefaultsAccountStatusKey"

struct AccountStatusManager {

    enum Status: Int {
        case logIn = 1
        case visit = 0
    }
    
    static let shared = AccountStatusManager()
    
    public let statusVariable: Variable<Status>
    
    init() {
        guard let status = Status(rawValue: BlockyUserDefaults.integer(forKey: UserDefaultsAccountStatusKey)) else {
            statusVariable = Variable.init(.visit)
            return
        }
        statusVariable = Variable.init(status)
    }
    
    func logIn() {
        BlockyUserDefaults.storeInteger(Status.logIn.rawValue, forKey: UserDefaultsAccountStatusKey)
        statusVariable.value = .logIn
    }
    
    func logOut() {
        BlockyUserDefaults.storeInteger(Status.visit.rawValue, forKey: UserDefaultsAccountStatusKey)
        statusVariable.value = .visit
    }
}
