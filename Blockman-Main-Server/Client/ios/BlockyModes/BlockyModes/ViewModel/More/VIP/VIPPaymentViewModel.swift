//
//  VIPPaymentViewModel.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2018/3/1.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa

class VIPPaymentViewModel: BaseViewModel {
    override static var mappedController: BaseViewController.Type {return VIPPaymentViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return VIPPaymentOutput.self}
    
    override func initialize() {
        viewTitle.value = R.string.localizable.vip_pay_open()
    }
}

struct VIPPaymentOutput: ViewModelToViewOutput {
    let vipsDict: Driver<[String : [VIPEntity]]>
    let vipPayResult: Driver<Bool>
    let vipStatusText: Driver<String>
    
    init(viewModel: BaseViewModel) {
    let vipPaymentInput = viewModel.viewInput as! VIPPaymentInput
        
    vipsDict = VIPPaymentNetServer.fetchVIPPriceList().map { response -> [String : [[String : Any]]] in
            let vipDict = response["data"] as! [String : Any]
            return vipDict as! [String : [[String : Any]]]
        }.map { (vipDict) -> [String : [VIPEntity]] in
            vipDict.mapValues({ (dicts) -> [VIPEntity] in
                dicts.map({ (dict) -> VIPEntity in
                    VIPEntity(model: VIPModel.deserialize(from: dict)!)
                })
            })
        }.asDriver(onErrorJustReturn: [:])
        
        vipPayResult = vipPaymentInput.payInput.flatMapLatest {
            VIPPaymentNetServer.pay(vip: $0).map({ (response) -> Bool in
                let dict = response["data"] as! [String : Any]
                let diamondsNeed = dict["diamondsNeed"] as! Int
                guard diamondsNeed == 0 else {
                    return false
                }
                AccountInfoManager.shared.updateVIP(level: dict["vip"] as! Int, expireDate: dict["expireDate"] as! String)
                AccountPropertyManager.shared.updateDiamonds(dict["diamonds"] as! Int)
                return true
            })
            .asDriver(onErrorJustReturn: false)
        }
        
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
