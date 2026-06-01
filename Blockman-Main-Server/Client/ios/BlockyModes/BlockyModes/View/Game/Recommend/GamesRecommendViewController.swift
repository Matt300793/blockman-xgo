//
//  GamesViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/17.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class GamesRecommendViewController: BaseViewController {
    
    override var inputType: ViewToViewModelInput.Type? {return GamesRecommendInput.self}
    
    fileprivate let dataSource = BMTableViewDataSource(reuseCellType: GamesRecommendTableCell.self)
    fileprivate let refreshPublish = PublishSubject<()>()
    fileprivate var changeAnothersPublish = PublishSubject<()>()
    private weak var tableView: BMTableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.set([SectionObject(items: []), SectionObject(items: [])])
        refreshPublish.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false , animated: true)
    }
    
    override func createAndLayoutChildViews() {
        super.createAndLayoutChildViews()
        
        let bannerHeaderView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.width, height: 156))
        bannerHeaderView.image = R.image.game_bannar_bg()
        bannerHeaderView.isUserInteractionEnabled = true
        
        let bannerView = SDCycleScrollView(frame: bannerHeaderView.bounds.insetBy(dx: 10, dy: 10), imageNamesGroup: ["game_banner"])
        bannerView?.bannerImageViewContentMode = .scaleAspectFill
        bannerHeaderView.addSubview(bannerView!)
        
        tableView = BMTableView().addTo(superView: view).configure { (tableView) in
            tableView.estimatedRowHeight = 0
            tableView.estimatedSectionFooterHeight = 0
            tableView.estimatedSectionHeaderHeight = 0
            tableView.tableHeaderView = bannerHeaderView
            tableView.bmDelegate = self
            tableView.bmDataSource = dataSource
            tableView.headerRefreshEnable()
            tableView.register(cellForClass: GamesRecommendTableCell.self)
        }.layout { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        
        let recommendOutput = output as! GamesRecommendOutput
        recommendOutput.recommendResults.drive(onNext: { [unowned self] object in
            self.tableView?.endRefreshing()
            guard object.itemsCount() != 0 else {
                if self.dataSource.sectionObject(for: 0).itemsCount() == 0 {
                    self.dataSource.replace(object: object, at: 0)
                }
                return
            }
            self.dataSource.replace(object: object, at: 0)
            self.tableView?.reloadData()
        }).disposed(by: disposeBag)
        
        recommendOutput.changeAnotherResults.drive(onNext: { [unowned self] object in
            guard object.itemsCount() != 0 else { return }
            self.dataSource.replace(object: object, at: 0)
            self.tableView?.reloadSections([0], with: .automatic)
        }).disposed(by: disposeBag)
        
        recommendOutput.recentlyPlayResults.drive(onNext: { [unowned self] object in
            self.tableView?.endRefreshing()
            guard object.itemsCount() != 0 else { return }
            self.dataSource.replace(object: object, at: 1)
            self.tableView?.reloadSections([1], with: .none)
        }).disposed(by: disposeBag)
    }
}

extension GamesRecommendViewController: BMTableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let entity = dataSource.sectionObject(for: indexPath.section).item(at: indexPath.row)
        return entity.itemHeight
    }
    
    func tableViewDidRefresh(_ tableView: BMTableView) {
        refreshPublish.onNext(())
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 1 else {return nil}
        
        let headerView = UIView()
        UIButton().addTo(superView: headerView).configure({ (button) in
            button.setDefaultStyle(fontSize: 15)
            button.setImage(R.image.game_change_anothers(), for: .normal)
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            button.setTitle(NSLocalizedString("change_another", comment: "换一批"), for: .normal)
            button.rx.tap.asDriver().throttle(0.5).drive(onNext: { [unowned self] in
                AnalysisManager.trackEvent(AnalysisManager.Event.home_change)
                self.changeAnothersPublish.onNext(())
            }).disposed(by: disposeBag)
        }).layout(snapKitMaker: { (make) in
            make.top.equalToSuperview().offset(3)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 184, height: 40))
        })
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 1 else {return 0.01}
        return 56
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let sectionHeaderHeight: CGFloat = 98
        
        if (scrollView.contentSize.height - scrollView.height) < sectionHeaderHeight {
            return
        }
        
        if scrollView.contentOffset.y <= sectionHeaderHeight, scrollView.contentOffset.y >= 0 {
            scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } else if scrollView.contentOffset.y >= sectionHeaderHeight {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

class GamesRecommendInput: ViewToViewModelInput {
    let changeAnothersInput: Driver<()>
    let refreshInput: Driver<()>
    
    required init(view: BaseViewController) {
        let gamesRecommendView = view as! GamesRecommendViewController
        refreshInput = gamesRecommendView.refreshPublish.asDriver(onErrorJustReturn: ())
        changeAnothersInput = gamesRecommendView.changeAnothersPublish.asDriver(onErrorJustReturn: ())
    }
}
