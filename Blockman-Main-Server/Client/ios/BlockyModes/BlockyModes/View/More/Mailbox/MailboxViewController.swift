//
//  MailboxViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/9.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MailboxViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return MailboxInput.self}
    
    fileprivate weak var tableView: BMTableView?
    fileprivate let refreshMailsBehavior = BehaviorSubject.init(value: ())
    fileprivate let clearMailsPublish = PublishSubject<[Int64]>()
    fileprivate let dataSource = BMTableViewDataSource(reuseCellType: MailboxTableCell.self)
    private var firstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.mail_clear()?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.clearMails))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        if firstAppear {
            firstAppear = false
            return
        }
        let newItems = dataSource.sectionObject(for: 0).items.filter {
            let entity = $0 as! MailboxEntity
            return entity.status != .deleted
        }
        navigationItem.rightBarButtonItem?.isEnabled = newItems.count != 0
        let sectionObject = SectionObject(items: newItems)
        dataSource.set([sectionObject])
        tableView?.reloadData()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            tableView!.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview().inset(view.safeAreaInsets.bottom)
            })
        }
    }
    
    override func createAndLayoutChildViews() {
        tableView = BMTableView().addTo(superView: view).configure({ (tableView) in
            tableView.register(cellForClass: MailboxTableCell.self)
            tableView.bmDataSource = self.dataSource
            tableView.bmDelegate = self
            tableView.headerRefreshEnable()
            tableView.showLoadingHolder()
        }).layout(snapKitMaker: { (make) in
            make.edges.equalToSuperview()
        })
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let mailOutput = output as! MailboxOutput
        mailOutput.mailResults.drive(onNext: { [weak self] (sectionObject) in
            self?.tableView?.endRefreshing()
            self?.navigationItem.rightBarButtonItem?.isEnabled = sectionObject.items.count != 0
            guard sectionObject.items.count != 0 else {
                self?.tableView?.inNoData(holderText: R.string.localizable.have_no_mails())
                return
            }
            self?.tableView?.dismissLoadingHolder()
            self?.dataSource.set([sectionObject])
            self?.tableView?.reloadData()
        }).disposed(by: disposeBag)
        
        mailOutput.clearMailsResult.drive(onNext: { [unowned self] (isSuccessful) in
            if isSuccessful {
                BlockyHUD.showText(R.string.localizable.common_delete_success(), inView: self.view)
                self.dataSource.removeAll()
                self.tableView?.reloadData()
                self.tableView?.inNoData(holderText: R.string.localizable.have_no_mails())
            }else {
                BlockyHUD.showText(R.string.localizable.common_delete_fail(), inView: self.view)
            }
        }).disposed(by: disposeBag)
    }
    
    @objc private func clearMails() {
        BlockyAlert.show(title: R.string.localizable.notification(), message: R.string.localizable.whether_clear_all_mails(), showCancel: true).done { [unowned self]_ in
            let entities = self.dataSource.sectionObject(for: 0).items as! [MailboxEntity]
            self.clearMailsPublish.onNext(entities.map({
                $0.id
            }))
        }
    }
}

extension MailboxViewController: BMTableViewDelegate {
    func tableViewDidRefresh(_ tableView: BMTableView) {
        refreshMailsBehavior.onNext(())
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let entity = dataSource.sectionObject(for: 0).item(at: indexPath.row)
        return entity.itemHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = dataSource.sectionObject(for: 0).item(at: indexPath.row)
        AppDelegate.globalServive().pushViewModel(MailContentViewModel.self, params: entity, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}


struct MailboxInput: ViewToViewModelInput {
    let refreshMailsInput: Driver<()>
    let clearMailsInput: Driver<[Int64]>
    
    init(view: BaseViewController) {
        let mailView = view as! MailboxViewController
        refreshMailsInput = mailView.refreshMailsBehavior.asDriver(onErrorJustReturn: ())
        clearMailsInput = mailView.clearMailsPublish.asDriver(onErrorJustReturn: [])
    }
}
