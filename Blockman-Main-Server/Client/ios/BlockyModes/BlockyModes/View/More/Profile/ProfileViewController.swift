//
//  ProfileViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/17.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {
    
    override var inputType: ViewToViewModelInput.Type? {return ProfileInput.self}
    
    fileprivate var accountStatus: AccountStatusManager.Status?
    fileprivate let dataSource = BMTableViewDataSource(reuseCellType: ProfileTableCell.self)
    private weak var tableView: BMTableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.title = R.string.localizable.tab_title_profile()
        
        AccountStatusManager.shared.statusVariable.asObservable().subscribe(onNext: { [weak self] in
            self?.accountStatus = $0
        })
        .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func createAndLayoutChildViews() {
        
        let profileInfoV = ProfileInfoView().addTo(superView: view).configure { [unowned self] (profileView) in
            profileView.delegate = self
        }.layout { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(170)
        }
        
        tableView = BMTableView().addTo(superView: view).configure { [unowned self] (tableView) in
            tableView.bmDelegate = self
            tableView.bmDataSource = self.dataSource
            tableView.register(cellForClass: ProfileTableCell.self)
        }.layout { (make) in
            make.top.equalTo(profileInfoV.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let profileOutput = output as! ProfileOutput
        profileOutput.profileResults.drive(onNext: { [unowned self] (objects) in
            self.dataSource.set(objects)
            self.tableView?.reloadData()
        }).disposed(by: disposeBag)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            tableView!.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview().inset(view.safeAreaInsets.bottom)
            })
        }
    }
}

struct ProfileInput: ViewToViewModelInput {
    init(view: BaseViewController) {
    }
}

extension ProfileViewController: ProfileInfoViewDelegate {
    func profileViewDidTap(_ profileView: ProfileInfoView) {
        AnalysisManager.trackEvent(AnalysisManager.Event.more_persinfo)
        AppDelegate.globalServive().pushViewModel(ProfileDetailViewModel.self, params: nil, animated: true)
    }
}

extension ProfileViewController: BMTableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let entity = dataSource.sectionObject(for: indexPath.section).item(at: indexPath.row)
        return entity.itemHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return margin_12
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            AnalysisManager.trackEvent(AnalysisManager.Event.me_Shop)
            DecorationControllerManager.shared.removeFromParent()
            AppDelegate.globalServive().pushViewModel(DecorationShopViewModel.self, params: nil, animated: true)
        case (0, 1):
            AppDelegate.globalServive().pushViewModel(VIPViewModel.self, params: nil, animated: true)
        case (0, 2):
            AppDelegate.globalServive().pushViewModel(RechargeViewModel.self, params: nil, animated: true)
        case (0, 3):
            AppDelegate.globalServive().pushViewModel(MailboxViewModel.self, params: nil, animated: true)
        case (1, 0):
            AnalysisManager.trackEvent(AnalysisManager.Event.more_setup)
            AppDelegate.globalServive().pushViewModel(SettingViewModel.self, params: nil, animated: true)
        default:
            break
        }
    }
}
