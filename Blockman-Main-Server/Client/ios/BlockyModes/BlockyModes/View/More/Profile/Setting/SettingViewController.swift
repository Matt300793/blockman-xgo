//
//  SettingViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/23.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class SettingViewController: BaseViewController {
    
    override var inputType: ViewToViewModelInput.Type? {return SettingInput.self}
    
    fileprivate let dataSource = BMTableViewDataSource(reuseCellType: ProfileTableCell.self)
    private weak var tableView: BMTableView?
    private weak var logOutButton: UIButton?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func createAndLayoutChildViews() {
        
        tableView = BMTableView().addTo(superView: view).configure { [unowned self] (tableView) in
            tableView.bounces = false
            tableView.bmDelegate = self
            tableView.bmDataSource = self.dataSource
            tableView.register(cellForClass: ProfileTableCell.self)
            }.layout { (make) in
                make.edges.equalToSuperview()
        }
        
        logOutButton = UIButton().addTo(superView: view).configure({ (button) in
            button.setDefaultStyle()
            button.setTitle(NSLocalizedString("log_out", comment: "退出登录"), for: .normal)
        }).layout(snapKitMaker: { (make) in
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: view.width * 0.65, height: 40))
            make.bottom.equalToSuperview().offset(-20)
        })
        AccountStatusManager.shared.statusVariable.asDriver().map({
            $0 == AccountStatusManager.Status.visit
        }).drive(logOutButton!.rx.isHidden).disposed(by: disposeBag)
        
        logOutButton!.rx.tap.subscribe(onNext: {
            BlockyAlert.show(title: R.string.localizable.notification(), message: NSLocalizedString("is_sure_log_out", comment: "是否退出当前账号?"), showCancel: true).done(closure: { alert in
                AccountStatusManager.shared.logOut()
                BlockyUserDefaults.removeValue(forKey: BlockyUserDefaults.dailyWatchVideoAdsTimeIntervalKey)
                AnalysisManager.trackEvent(AnalysisManager.Event.more_exit_suc)
                AppDelegate.globalServive().popViewModel(animated: true)
            })
        }).disposed(by: disposeBag)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            tableView!.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview().inset(view.safeAreaInsets.bottom)
            })
            
            logOutButton!.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview().inset(view.safeAreaInsets.bottom)
            })
        }
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let settingOutput = output as! SettingOutput
        
        settingOutput.settingResults.drive(onNext: { (objects) in
            self.dataSource.set(objects)
            self.tableView?.reloadData()
        }).disposed(by: disposeBag)
    }
}

extension SettingViewController: BMTableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let entity = dataSource.sectionObject(for: indexPath.section).item(at: indexPath.row)
        return entity.itemHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            if AccountStatusManager.shared.statusVariable.value == .visit {
                AppDelegate.globalServive().pushViewModel(AboutMeViewModel.self, params: nil, animated: true)
            }else {
                AppDelegate.globalServive().pushViewModel(AccountSecurityViewModel.self, params: nil, animated: true)
            }
        case (0, 1):
            //            navigationController?.pushViewController(MessageNotificationViewController(viewModelType: nil), animated: true)
            AppDelegate.globalServive().pushViewModel(AboutMeViewModel.self, params: nil, animated: true)
        default:
            break
        }
    }
}
struct SettingInput: ViewToViewModelInput {
    init(view: BaseViewController) {
    }
}
