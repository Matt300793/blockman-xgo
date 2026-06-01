//
//  RegexMatch.swift
//  BlockyModes
//
//  Created by KiBen on 2017/11/2.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation

struct RegexMatch {
    let regex: NSRegularExpression?
    
    init(pattern: String) {
        regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
    
    func match(input: String) -> Bool {
        if let matcheResults = regex?.matches(in: input, options: [], range: NSMakeRange(0, input.count)) {
            return matcheResults.count > 0
        }else {
            return false
        }
    }
}

