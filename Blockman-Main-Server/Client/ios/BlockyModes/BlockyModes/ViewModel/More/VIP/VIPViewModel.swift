//
//  VIPViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/28.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa

class VIPViewModel: BaseViewModel {
    override static var mappedController: BaseViewController.Type {return VIPViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return VIPOutput.self}
    
    override func initialize() {
        viewTitle.value = "VIP"
    }
    
    public func vipPriceAttributedText(vipLevel: Int) -> NSAttributedString {
        var monthPrice = ""
        var yearPrice = ""
        switch vipLevel {
        case 0:
            monthPrice = "60"
            yearPrice = "600"
        case 1:
            monthPrice = "320"
            yearPrice = "3200"
        case 2:
            monthPrice = "1280"
            yearPrice = "12800"
        default:
            break
        }
        let attachment = NSTextAttachment()
        attachment.image = R.image.common_diamond()
        attachment.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
        let bcube = NSAttributedString(attachment: attachment)
        
        let monthPriceString = monthPrice + "/" + R.string.localizable.month()
        let yearPriceString = yearPrice + "/" + R.string.localizable.year()
        
        let priceAttributedString = NSMutableAttributedString(string: monthPriceString, attributes: [NSFontAttributeName: UIFont.size12,
            NSForegroundColorAttributeName: UIColor.white])
        priceAttributedString.insert(bcube, at: monthPrice.count)
        priceAttributedString.append(NSAttributedString(string: " "))
        
        let yearPriceAttrString = NSMutableAttributedString(string: yearPriceString, attributes: [NSFontAttributeName: UIFont.size12,
                                                                                                  NSForegroundColorAttributeName: UIColor.white])
        yearPriceAttrString.addAttributes([NSForegroundColorAttributeName: R.color.appColor._fa800()], range: (yearPriceString as NSString).range(of: yearPrice))
        yearPriceAttrString.insert(bcube, at: yearPrice.count)
        priceAttributedString.append(yearPriceAttrString)
        return priceAttributedString
    }
}

struct VIPOutput: ViewModelToViewOutput {
    let privilegeEntities: Driver<[[VIPPrivilegeEntity]]>
    let vipStatusText: Driver<String>
    
    init(viewModel: BaseViewModel) {
        let filePath = Bundle.main.path(forResource: "VIP-Privilege", ofType: ".plist")
        let privileges = NSArray.init(contentsOfFile: filePath!) as! [[[String : Any]]]
        let entities = privileges.map { (dicts) -> [VIPPrivilegeEntity] in
            dicts.map({ (dict) -> VIPPrivilegeEntity in
                VIPPrivilegeEntity(model: VIPPrivilegeModel.deserialize(from: dict)!)
            })
        }
        privilegeEntities = Driver.just(entities)
        
        vipStatusText = Driver.combineLatest(AccountInfoManager.shared.vip.asDriver(), AccountInfoManager.shared.vipExpireDate.asDriver()) { (vip, expireData) in
            switch vip {
            case 1:
                return "  " + String(format: NSLocalizedString("vip_title_has_vip_text", comment: ""), AccountInfoManager.shared.nickname.value, "VIP", expireData)
            case 2:
                return "  " + String(format: NSLocalizedString("vip_title_has_vip_text", comment: ""), AccountInfoManager.shared.nickname.value, "VIP+", expireData)
            case 3:
                return "  " + String(format: NSLocalizedString("vip_title_has_vip_text", comment: ""), AccountInfoManager.shared.nickname.value, "MVP", expireData)
            default:
                return "  " + String(format: NSLocalizedString("vip_title_text", comment: ""), AccountInfoManager.shared.nickname.value)
            }
        }
    }
}
