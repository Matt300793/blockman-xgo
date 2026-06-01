//
//  VIPPaymentViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/1.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VIPPaymentViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return VIPPaymentInput.self}
    
    private weak var tableView: BMTableView?
    private weak var statusLabel: UILabel?
    private weak var vipMenu: VIPMenu?
    fileprivate var vipsDict: [String : [VIPEntity]] = [:]
    fileprivate var payPublish = PublishSubject<String>()
    fileprivate let dataSource = BMTableViewDataSource(reuseCellType: VIPPaymentTableCell.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func createAndLayoutChildViews() {
        let topView = UIView().addTo(superView: view).configure { (view) in
            view.backgroundColor = R.color.appColor._fae7ca()
        }.layout { (make) in
            make.left.top.right.equalToSuperview().inset(10)
            make.height.equalTo(105)
        }
        
        let payLabel = UILabel().addTo(superView: topView).configure { (label) in
            label.backgroundColor = R.color.appColor._c8a16b()
            label.font = UIFont.size12
            label.textColor = R.color.appColor._fef1de()
            label.text = "  " + R.string.localizable.vip_pay_open()
        }.layout { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(30)
        }
        
        let portraitView = NetImageView().addTo(superView: topView).configure { (imageView) in
            imageView.imageWithUrlString(AccountInfoManager.shared.portraiUrl.value, placeHolder: R.image.common_default_userimage())
        }.layout { (make) in
            make.top.equalTo(payLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(CGSize(width: 55, height: 55))
        }
        
        UILabel().addTo(superView: topView).configure { (label) in
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.textColor = R.color.appColor._666666()
            label.text = AccountInfoManager.shared.nickname.value
        }.layout { (make) in
            make.left.equalTo(portraitView.snp.right).offset(10)
            make.centerY.equalTo(portraitView)
        }
        
        statusLabel = UILabel().addTo(superView: view).configure { (label) in
            label.backgroundColor = R.color.appColor._fae7ca()
            label.font = UIFont.size12
            label.textColor = R.color.appColor._666666()
        }.layout { (make) in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(topView.snp.bottom).offset(5)
            make.height.equalTo(50)
        }
        
        let vipMenu = VIPMenu().addTo(superView: view).layout { (make) in
            make.top.equalTo(statusLabel!.snp.bottom).offset(5)
            make.left.right.equalTo(statusLabel!)
            make.height.equalTo(40)
        }
        self.vipMenu = vipMenu
        vipMenu.rx.controlEvent(.valueChanged).subscribe(onNext: {[unowned self] in
            self.refreshVips(level: vipMenu.selectedIndex + 1)
        }).disposed(by: disposeBag)
        
        tableView = BMTableView().addTo(superView: view).configure { (tableView) in
            tableView.backgroundColor = R.color.appColor._cbad83()
            tableView.bmDataSource = self.dataSource
            tableView.bmDelegate = self
            tableView.register(cellForClass: VIPPaymentTableCell.self)
            tableView.showLoadingHolder()
        }.layout { (make) in
            make.top.equalTo(vipMenu.snp.bottom)
            make.left.right.equalTo(vipMenu)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            tableView!.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview().inset(view.safeAreaInsets.bottom)
            })
        }
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let vipPaymentOutput = output as! VIPPaymentOutput
        vipPaymentOutput.vipsDict.drive(onNext: { [unowned self](vipsDict) in
            vipsDict.isEmpty ? self.tableView?.inNoData() : self.tableView?.dismissLoadingHolder()
            self.vipsDict = vipsDict
            let vipLevel = AccountInfoManager.shared.vip.value
            guard vipLevel != 0 else {
                self.vipMenu?.selectedIndex = 0
                self.refreshVips(level: 1)
                return
            }
            self.vipMenu?.selectedIndex = vipLevel - 1
            self.refreshVips(level: vipLevel)
        }).disposed(by: disposeBag)
        
        vipPaymentOutput.vipPayResult.drive(onNext: { isSuccessful in
            BlockyAlert.show(title: NSLocalizedString("common_notification", comment: "提示"), message: isSuccessful ? R.string.localizable.decoration_pay_successful() : R.string.localizable.decoration_pay_failed()).done(closure: {_ in
                if isSuccessful {
                    AppDelegate.globalServive().popToRootViewModel(animated: true)
                }
            })
        }).disposed(by: disposeBag)
        
        vipPaymentOutput.vipStatusText.drive(statusLabel!.rx.text).disposed(by: disposeBag)
    }
    
    private func refreshVips(level: Int) {
        
        guard !vipsDict.isEmpty else { tableView?.inNoData(); return }
        
        guard let vips = vipsDict[String(level)] else {
            tableView?.inNoData(holderText: R.string.localizable.unable_pay_vip_lower_than_yours())
            return
        }
        
        tableView?.dismissLoadingHolder()
        dataSource.set([SectionObject(items: vips)])
        tableView?.reloadData()
    }
    
    fileprivate func pay(vip: VIPEntity) {
        if Int(vip.price)! > AccountPropertyManager.shared.diamonds.value {
            BlockyAlert.show(title: NSLocalizedString("common_notification", comment: "提示"), message: R.string.localizable.balance_not_enough_then_recharge(), showCancel: true).done(closure: { _ in
                AppDelegate.globalServive().pushViewModel(RechargeViewModel.self, params: nil, animated: true)
            })
            return
        }
        payPublish.onNext(vip.productID)
    }
}

extension VIPPaymentViewController: BMTableViewDelegate, VIPPaymentTableCellDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let entity = dataSource.sectionObject(for: indexPath.section).item(at: indexPath.row)
        return entity.itemHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = dataSource.sectionObject(for: indexPath.section).item(at: indexPath.row) as! VIPEntity
        pay(vip: entity)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let vipCell = cell as! VIPPaymentTableCell
        vipCell.delegate = self
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func vipPaymentCellDidTap(entity: VIPEntity) {
        pay(vip: entity)
    }
}

struct VIPPaymentInput: ViewToViewModelInput {
    let payInput: Driver<String>
    
    init(view: BaseViewController) {
        let payController = view as! VIPPaymentViewController
        payInput = payController.payPublish.asDriver(onErrorJustReturn: "")
    }
}
