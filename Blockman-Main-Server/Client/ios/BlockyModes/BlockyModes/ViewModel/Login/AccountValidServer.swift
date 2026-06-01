//
//  AccountVerifyServer.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/19.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation

enum VerifyResult {
    case successful
    case failed(message: String)
}

extension VerifyResult {
    var isValid: Bool {
        switch self {
        case .successful:
            return true
        default:
            return false
        }
    }
}

class VerifyServer {
    
    class func verify(account: String) -> VerifyResult {
        let result = RegexMatch(pattern: "^[a-zA-Z0-9_-]{3,12}$").match(input: account)
        return result ? .successful : .failed(message: NSLocalizedString("account_format_not_valid", comment: "账号格式不正确"))
    }
    
    class func verify(password: String, doublePassword: String?) -> VerifyResult {
        let regex = RegexMatch(pattern: "^[a-zA-Z0-9]{6,12}$")
        let firstResult = regex.match(input: password)
        guard let dPassword = doublePassword else {
            return firstResult ? .successful : .failed(message: NSLocalizedString("password_format_not_valid", comment: "密码格式不正确"))
        }
        
        let doubleResult = regex.match(input: dPassword)
        guard doubleResult else {
            return .failed(message: NSLocalizedString("password_format_not_valid", comment: "密码格式不正确"))
        }
        
        guard dPassword == password else {
            return .failed(message: NSLocalizedString("password_not_match", comment: "验证密码不匹配"))
        }
        
        return .successful
    }
    
    class func verify(phone: String) -> VerifyResult {
        let result = RegexMatch(pattern: "^1[0-9]{10}$").match(input: phone)
        return result ? .successful : .failed(message: NSLocalizedString("phone_number_format_not_valid", comment: "手机号码不正确"))
    }
    
    class func verify(email: String) -> VerifyResult {
        let result = RegexMatch(pattern: "^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]{2,3}+)+$").match(input: email)
        return result ? .successful : .failed(message: NSLocalizedString("email_format_not_valid", comment: "邮件格式不正确"))
    }
    
    class func verify(verificationCode: String, length: Int = 4) -> VerifyResult {
        let pattern = String.init(format: "^[0-9]{%d}$", length)
        let result = RegexMatch(pattern: pattern).match(input: verificationCode)
        return result ? .successful : .failed(message: NSLocalizedString("verofication_code_format_not_valid", comment: "验证码格式不正确"))
    }
}
