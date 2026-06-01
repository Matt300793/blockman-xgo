//
//  ShowErrorToast.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/9.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

protocol ShowErrorToast {
    func showAlert(withError error: BlockyError)
}

extension ShowErrorToast where Self: BaseViewController {
    func showAlert(withError error: BlockyError) {
        var errorText = ""
        switch error {
        // User
        case .accountExist:
            errorText = NSLocalizedString("the_account_exist", comment: "该账号已存在")
            
        case .nicknameExist:
            errorText = NSLocalizedString("the_nickname_exist", comment: "该昵称已存在")
            
        case .nicknameInvalid:
            errorText = NSLocalizedString("the_nickname_not_valid", comment: "昵称不合格")
            
        case .accountNotExist:
            errorText = NSLocalizedString("the_account_not_exist", comment: "该账号不存在")
            
        case .phoneHasBinded:
            errorText = NSLocalizedString("the_phone_has_been_used", comment: "该手机已被使用")
            
        case .phoneNotBind:
            errorText = NSLocalizedString("the_phone_not_bind_account", comment: "该手机未绑定账号")
            
        case .emailNotBindToUser:
            errorText = NSLocalizedString("email_not_bind_user", comment: "该邮箱未绑定账号")
            
        case .emailHasBeenBind:
            errorText = NSLocalizedString("email_has_been_used", comment: "该邮箱已被使用")
            
        case .userHasBindEmail:
            errorText = NSLocalizedString("account_has_bind_email", comment: "该账号已绑定邮箱")
            
        case .smsSendFailed:
            errorText = NSLocalizedString("the_msg_send_fail", comment: "短信发送失败")
            
        case .verificationCodeError:
            errorText = NSLocalizedString("the_verification_code_error", comment: "验证码错误")
            
        case .passwordError:
            errorText = NSLocalizedString("the_password_error", comment: "密码错误")
            
        case .noPermission:
            errorText = NSLocalizedString("no_permission", comment: "没有权限，请登录")
            
        case .systemNoDecoration:
            errorText = NSLocalizedString("the_system_has_no_the_decoration", comment: "系统无此装饰")
            
        case .userNoDecoration:
            errorText = NSLocalizedString("you_dont_have_decoration", comment: "您未拥有此装饰")
            
        default:
            errorText = NSLocalizedString("common_request_fail_retry", comment: "请求失败，请重试")
        }
        BlockyHUD.showText(errorText, inView: self.view.window!)
    }
    
}
