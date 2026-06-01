//
//  RechargeRecordViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/17.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RechargeRecordViewController: BaseViewController {
    
    override var inputType: ViewToViewModelInput.Type? {return RechargeRecordInput.self}
    
    fileprivate let currentPageVariable = Variable(0)
    fileprivate let dataSource = BMTableViewDataSource(reuseCellType: RechargeRecordTableCell.self)
    private weak var tableView: BMTableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func createAndLayoutChildViews() {
        
        tableView = BMTableView().addTo(superView: view).configure { [unowned self] (tableView) in
            tableView.bmDelegate = self
            tableView.bmDataSource = self.dataSource
            tableView.headerRefreshEnable()
            tableView.footerRefreshEnable()
            tableView.showLoadingHolder()
            tableView.register(cellForClass: RechargeRecordTableCell.self)
        }.layout { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let rechargeRecordOutput = output as! RechargeRecordOutput
        
        rechargeRecordOutput.recordResults.drive(onNext: { [unowned self] (object) in
            self.tableView?.endRefreshing()
            if object.itemsCount() == 0 {
                self.currentPageVariable.value == 0 ? self.tableView?.inNoData() : ()
                return
            }
            self.tableView?.dismissLoadingHolder()
            self.currentPageVariable.value == 0 ? self.dataSource.set([object]) : self.dataSource.sectionObject(for: 0).append(items: object.items)
            self.tableView?.reloadData()
        }).disposed(by: disposeBag)
    }
}

extension RechargeRecordViewController: BMTableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let entity = dataSource.sectionObject(for: indexPath.section).item(at: indexPath.row)
        return entity.itemHeight
    }
    
    func tableViewDidRefresh(_ tableView: BMTableView) {
        currentPageVariable.value = 0
    }
    
    func tableViewDidLoadMore(_ tableView: BMTableView) {
        currentPageVariable.value += 1
    }
}

struct RechargeRecordInput: ViewToViewModelInput {
    let currentPageInput: Driver<Int>
    
    init(view: BaseViewController) {
        let recordView = view as! RechargeRecordViewController
        currentPageInput = recordView.currentPageVariable.asDriver()
    }
}
