//
//  AccountSecurityViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/24.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class AccountSecurityViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return AccountSecurityInput.self}
    
    fileprivate let dataSource = BMTableViewDataSource(reuseCellType: ProfileTableCell.self)
    fileprivate weak var tableView: BMTableView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView?.reloadData()
    }

    override func createAndLayoutChildViews() {
        tableView = BMTableView().addTo(superView: view).configure { [unowned self] (tableView) in
            tableView.bmDelegate = self
            tableView.bmDataSource = self.dataSource
            tableView.register(cellForClass: ProfileTableCell.self)
        }.layout { (make) in
            make.edges.equalToSuperview()
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
        let securityOutput = output as! AccountSecurityOutput
        
        securityOutput.accountSecurityResults.drive(onNext: { (object) in
            self.dataSource.set([object])
            self.tableView?.reloadData()
        }).disposed(by: disposeBag)
    }
}

extension AccountSecurityViewController: BMTableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let entity = dataSource.sectionObject(for: indexPath.section).item(at: indexPath.row)
        return entity.itemHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            guard AccountInfoManager.shared.loginFromThird.value else {
                AnalysisManager.trackEvent(AnalysisManager.Event.more_chpass_click)
                AppDelegate.globalServive().pushViewModel(ModifyPasswordViewModel.self, params: nil, animated: true)
                return
            }
            fallthrough
        case (0, 1):
            guard !AccountInfoManager.shared.hasBindedEmail() else { //是否绑定邮箱
                BlockyAlert.show(title: NSLocalizedString("notification", comment: "提示"), message: NSLocalizedString("is_unbind_email", comment: "是否解绑邮箱"), showCancel: true).done(closure: {_ in
                    UserNetServer.unbindEmail().map({_ -> BlockyResult in .success })
                        .asDriver(onErrorJustReturn: .fail(BlockyError.unKnown))
                        .drive(onNext: {[unowned self]  result in
                            switch result {
                            case .success:
                                AccountInfoManager.shared.removeBindEmail()
                                self.tableView?.reloadRows(at: [indexPath], with: .none)
                            case let .fail(error):
                                self.showAlert(withError: error)
                            }
                        }).disposed(by: self.disposeBag)
                })
                return
            }
            AnalysisManager.trackEvent(AnalysisManager.Event.more_email_click)
            AppDelegate.globalServive().pushViewModel(BindEmailViewModel.self, params: nil, animated: true)
        case (0, 2):
            guard AccountInfoManager.shared.hasBindedPhone() else { //是否绑定手机
                AnalysisManager.trackEvent(AnalysisManager.Event.more_moi_click)
                AppDelegate.globalServive().pushViewModel(BindPhoneViewModel.self, params: nil, animated: true)
                return
            }
            AppDelegate.globalServive().pushViewModel(UnbindPhoneViewModel.self, params: nil, animated: true)
        default:
            break
        }
    }
}

struct AccountSecurityInput: ViewToViewModelInput {
    init(view: BaseViewController) {
    }
}
