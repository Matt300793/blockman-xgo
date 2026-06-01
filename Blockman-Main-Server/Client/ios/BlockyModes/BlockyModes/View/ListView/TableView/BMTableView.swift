//
//  BMTableView.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2018/2/4.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

protocol BMTableViewDelegate: UITableViewDelegate {
    func tableViewDidRefresh(_ tableView: BMTableView)
    func tableViewDidLoadMore(_ tableView: BMTableView)
}

extension BMTableViewDelegate {
    func tableViewDidRefresh(_ tableView: BMTableView) { }
    func tableViewDidLoadMore(_ tableView: BMTableView) { }
}

class BMTableView: UITableView, LoadingHolderEnable {
    
    public weak var bmDelegate: BMTableViewDelegate? = nil {
        didSet {
            delegate = bmDelegate
        }
    }
    
    public weak var bmDataSource: BMTableDataSource? = nil {
        didSet {
            dataSource = bmDataSource
        }
    }
    
    override func headerDidRefresh() {
        bmDelegate?.tableViewDidRefresh(self)
    }
    
    override func footerDidRefresh() {
        bmDelegate?.tableViewDidLoadMore(self)
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        separatorStyle = .none
        backgroundColor = R.color.appColor._e7c99e()
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
