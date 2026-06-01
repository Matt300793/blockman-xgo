//
//  GamesCategoryViewController.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/31.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GamesCategoryViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return GamesCategoryInput.self}
    
    fileprivate weak var collectionView: BMCollectionView?
    fileprivate weak var categoryMenu: GamesCategoryMenu?
    fileprivate weak var sortMaskMenu: GamesCategorySortMaskMenu?
    
    fileprivate let dataSource = BMCollectionViewDataSource(reuseCellType: GameCollectionCell.self)
    fileprivate var currentPage = 0
    fileprivate let filterConditionPublish = PublishSubject<(Int, String, Int)>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterConditionPublish.onNext((categoryMenu!.selectedCategory, sortMaskMenu!.selectedSortTypeTuple.1, currentPage))
    }
    
    override func createAndLayoutChildViews() {
        
        let topMenu = UIView().addTo(superView: view).configure { (menu) in
            menu.backgroundColor = R.color.appColor._e7c99e()
        }.layout { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(36)
        }
        
        let sortButton = UIButton().addTo(superView: topMenu).configure { (button) in
            button.setTitleColor(R.color.appColor._666666(), for: .normal)
            button.backgroundColor = R.color.appColor._fae7ca()
            button.titleLabel?.font = UIFont.size13
        }.layout { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(90)
        }
        sortButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.collectionView?.bringSubview(toFront: self.sortMaskMenu!)
            self.sortMaskMenu?.isHidden = false
        }).disposed(by: disposeBag)
        
        categoryMenu = GamesCategoryMenu().addTo(superView: topMenu).layout(snapKitMaker: { (make) in
            make.left.equalTo(sortButton.snp.right).offset(1)
            make.top.right.bottom.equalToSuperview()
        })
        categoryMenu!.rx.controlEvent(.valueChanged).subscribe(onNext: { [unowned self] in
            self.currentPage = 0
            self.filterConditionPublish.onNext((self.categoryMenu!.selectedCategory, self.sortMaskMenu!.selectedSortTypeTuple.1, 0))
        }).disposed(by: disposeBag)
        
        collectionView = BMCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).addTo(superView: view).configure({ [unowned self] (collectionView) in
            collectionView.bmDelegate = self
            collectionView.bmDataSource = self.dataSource
            collectionView.register(cellForClass: GameCollectionCell.self)
            collectionView.headerRefreshEnable()
            collectionView.showLoadingHolder()
        }).layout(snapKitMaker: { (make) in
            make.top.equalToSuperview().offset(36)
            make.left.right.bottom.equalToSuperview()
        })
        
        sortMaskMenu = GamesCategorySortMaskMenu().addTo(superView: collectionView!).configure({ (sortMenu) in
            sortMenu.isHidden = true
        }).layout(snapKitMaker: { make in
            make.left.top.equalToSuperview()
            make.size.equalTo(view.size)
        })
        sortButton.setTitle(sortMaskMenu?.selectedSortTypeTuple.0, for: .normal)
        sortMaskMenu!.rx.controlEvent(.valueChanged).subscribe(onNext: { [unowned self] in
            self.sortMaskMenu?.isHidden = true
            self.currentPage = 0
            sortButton.setTitle(self.sortMaskMenu!.selectedSortTypeTuple.0, for: .normal)
            self.filterConditionPublish.onNext((self.categoryMenu!.selectedCategory, self.sortMaskMenu!.selectedSortTypeTuple.1, 0))
        }).disposed(by: disposeBag)
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let categoryOutput = output as! GamesCategoryOutput
        categoryOutput.gamesResult.drive(onNext: { [unowned self] object in
            self.collectionView?.endRefreshing()
            if object.itemsCount() == 0 {
                self.currentPage == 0 ? self.collectionView?.inNoData() : ()
                return
            }
            self.collectionView?.dismissLoadingHolder()
            self.currentPage == 0 ? self.dataSource.set([object]) : self.dataSource.sectionObject(for: 0).append(items: object.items)
            self.collectionView?.reloadData()
        }).disposed(by: disposeBag)
    }
}

class GamesCategoryInput: ViewToViewModelInput {
    let filterConditionInput: Driver<(Int, String, Int)>
    
    required init(view: BaseViewController) {
        let categoryView = view as! GamesCategoryViewController
        filterConditionInput = categoryView.filterConditionPublish.asDriver(onErrorJustReturn: (0, "", 0))
    }
}

extension GamesCategoryViewController: BMCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let entity = dataSource.sectionObject(for: indexPath.section).item(at: indexPath.item)
        return entity.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: margin_16, bottom: 20, right: margin_16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let entity = dataSource.sectionObject(for: indexPath.section).item(at: indexPath.item) as! GameCollectionCellEntity
        AnalysisManager.trackEvent(AnalysisManager.Event.home_classgames, parameters: ["gameID" : entity.gameId])
        AppDelegate.globalServive().pushViewModel(GameDetailViewModel.self, params: entity.gameId, animated: true)
    }
    
    func collectionViewDidRefresh(_ collectionView: BMCollectionView) {
        currentPage = 0
        filterConditionPublish.onNext((categoryMenu!.selectedCategory, sortMaskMenu!.selectedSortTypeTuple.1, currentPage))
    }
    
    func collectionViewDidLoadMore(_ collectionView: BMCollectionView) {
        currentPage += 1
        filterConditionPublish.onNext((categoryMenu!.selectedCategory, sortMaskMenu!.selectedSortTypeTuple.1, currentPage))
    }
}
