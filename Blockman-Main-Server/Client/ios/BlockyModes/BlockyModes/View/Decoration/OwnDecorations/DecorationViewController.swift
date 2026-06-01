//
//  DecorationViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/17.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import BlockModsGameKit
import RxSwift
import RxCocoa

class DecorationViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return DecorationInput.self}
    
    fileprivate weak var decorationMenu: DecorationMenu!
    fileprivate weak var decorationsView: DecorationsView!
    fileprivate weak var decorationCategorySuspendView: DecorationCategorySuspendView!
    fileprivate var currentEquipmentButton: UIButton!
    
    fileprivate var decorationCategoryPublish: PublishSubject<Int> = PublishSubject()
    fileprivate var decorationUpdtePublish: PublishSubject<Int> = PublishSubject()
    fileprivate var decorationDeletePublish: PublishSubject<Int> = PublishSubject()
    fileprivate var decorationCurrentUsingBehavior = BehaviorSubject(value: ())
    fileprivate var decorationsCategroyDict: [Int : [DecorationEntity]] = [:] // 存着每个分类对应的装饰
    fileprivate var selectedDecoration: DecorationEntity!
    fileprivate var selectedDecorationsDict: [Int : DecorationEntity] = [:] // 存着选中的所有装饰 key: 每件装饰的typeID value: 装饰
    private var firstAppear: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AccountStatusManager.shared.statusVariable.asObservable()
        .do(onNext: {[unowned self] status in
            self.decorationsCategroyDict.removeAll()
            self.selectedDecorationsDict.removeAll()
            if self.decorationsView.currentPage == 0 {
                self.decorationCurrentUsingBehavior.onNext(())
            }else {
                self.decorationCategoryPublish.onNext(self.decorationsView.currentPage)
            }
            return
        })
        .map({
            $0 == AccountStatusManager.Status.visit
        })
        .bind(to: decorationCategorySuspendView.rx.isHidden)
        .disposed(by: disposeBag)
        
        AccountInfoManager.shared.gender.asDriver()
        .drive(onNext: { gender in
            DecorationControllerManager.shared.changeGender(gender.rawValue)
            return
        })
        .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        DecorationControllerManager.shared.add(toParent: self, layout: { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(DecorationControllerManager.decorationControllerHeight)
        }) {
            DecorationControllerManager.shared.resetToDefault()
            for (_, decoration) in self.selectedDecorationsDict {
                DecorationControllerManager.shared.useDecoration(resourceID: decoration.resourceID)
            }
        }
    }
    
    override func createAndLayoutChildViews() {
        
        let shopBarButton = UIBarButtonItem(image: R.image.decoration_shop()?.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
        shopBarButton.rx.tap.subscribe(onNext: { _ in
            DecorationControllerManager.shared.removeFromParent()
            AnalysisManager.trackEvent(AnalysisManager.Event.dress_Shop)
            AppDelegate.globalServive().pushViewModel(DecorationShopViewModel.self, params: nil, animated: true)
        }).disposed(by: disposeBag)
        self.navigationItem.rightBarButtonItem = shopBarButton
        
        DecorationControllerManager.shared.add(toParent: self, layout: { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(DecorationControllerManager.decorationControllerHeight)
        })
        
        decorationCategorySuspendView = DecorationCategorySuspendView(items: []).addTo(superView: view).layout { (make) in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(margin_14)
            make.size.equalTo(CGSize(width: 45, height: 195))
        }
        decorationCategorySuspendView.rx.controlEvent(.valueChanged).asDriver().filter {[unowned self] in
            self.decorationCategorySuspendView.selectedImageURLString != nil
            }.drive(onNext: { [unowned self] in
                if let decoration = self.fetchDecoration(ofThumbnailURLString: self.decorationCategorySuspendView.selectedImageURLString!)  { // 更新当前选中的装饰
                    self.selectedDecoration = decoration
                    self.decorationDeletePublish.onNext(self.selectedDecoration.id) // 卸下对应的装饰
                }
            }).disposed(by: disposeBag)
        
        let currentEquipmentButton = UIButton().addTo(superView: view).configure { (button) in
            button.setBackgroundImage(R.image.decoration_equipment(), for: .normal)
            button.setBackgroundImage(R.image.decoration_equipment_selected(), for: .selected)
            button.isSelected = true
            }.layout { (make) in
                make.left.equalToSuperview()
                make.top.equalTo(DecorationControllerManager.decorationControllerHeight)
                make.size.equalTo(CGSize(width: 70, height: 50))
        }
        currentEquipmentButton.rx.tap.asDriver().do(onNext: {
            currentEquipmentButton.isSelected = true
        }).drive(onNext: {[unowned self] in
            self.decorationMenu.selectedIndex = NSNotFound
            self.decorationsView.setCurrentPage(0, animated: false)
            self.updateCurrentUsingDecorations()
        }).disposed(by: disposeBag)
        self.currentEquipmentButton = currentEquipmentButton
        
        decorationMenu = DecorationMenu().addTo(superView: view).layout { (make) in
            make.left.equalTo(currentEquipmentButton.snp.right)
            make.right.equalToSuperview()
            make.top.equalTo(currentEquipmentButton)
            make.height.equalTo(50)
        }
        decorationMenu.rx.controlEvent(.valueChanged).asDriver().do(onNext: {
            currentEquipmentButton.isSelected = false
        }).drive(onNext: {[unowned self] in
            DebugLog("点击了collectionview menu index \(self.decorationMenu.selectedIndex)")
            self.decorationsView.setCurrentPage(self.decorationMenu.selectedIndex + 1, animated: false)
            self.updateDecorations(category: self.decorationMenu.selectedIndex + 1)
            self.refreshCategorySuspendView(category: self.decorationMenu.selectedIndex + 1)
        }).disposed(by: disposeBag)
        
        decorationsView = DecorationsView().addTo(superView: view).configure({ (decorationView) in
            decorationView.dataSource = self
            decorationView.delegate = self
        }).layout { (make) in
            make.top.equalTo(decorationMenu.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-49)
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            decorationsView.snp.remakeConstraints { (make) in
                make.top.equalTo(decorationMenu.snp.bottom)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().inset(view.safeAreaInsets.bottom)
            }
        }
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let decorationOutput = output as! DecorationOutput
        
        // 正在使用的装饰
        decorationOutput.decorationsCurrentUsing.drive(onNext: { [unowned self] decorationEntities in
            
            self.decorationsView.endRefreshing(inPage: self.decorationsView.currentPage)
            self.decorationsCategroyDict[0] = decorationEntities
            guard !decorationEntities.isEmpty else {
                self.decorationsView.showHolderViewWhenErrorOrEmpty(inPage: 0)
                return
            }
            self.decorationsView.dismissHolderView(inPage: 0)
            self.decorationsView.reloadData(forPage: 0)
            self.selectedDecorationsDict.removeAll()
            for (index, decoration) in decorationEntities.enumerated() {
                self.decorationsView.selectItem(inPage: 0, atIndex: index)
                self.selectedDecorationsDict[decoration.typeID] = decoration
                if self.firstAppear { // 第一次加载完成后，渲染正在使用的装饰
                    DecorationControllerManager.shared.useDecoration(resourceID: decoration.resourceID)
                }
            }
            self.firstAppear = false // 第一次加载完成后，设置为false
        }).disposed(by: disposeBag)
        
        // 当前查看的装饰分类
        decorationOutput.decorationsOfCategory.drive(onNext: { [unowned self] decorationEntities in
            
            self.decorationsView.endRefreshing(inPage: self.decorationsView.currentPage)
            self.decorationsCategroyDict[self.decorationsView.currentPage] = decorationEntities
            guard !decorationEntities.isEmpty else {
                self.decorationsView.showHolderViewWhenErrorOrEmpty(inPage: self.decorationsView.currentPage)
                return
            }
            self.decorationsView.dismissHolderView(inPage: self.decorationsView.currentPage)
            self.decorationsView.reloadDataForCurrentPage()
            
            let preSelectIndexes = decorationEntities.filter({
                $0.isUsing
            }).map({ decorationEntities.index(of: $0) })
            self.preSelectItems(inPage: self.decorationMenu.selectedIndex + 1, atIndexes: preSelectIndexes)
            
            self.refreshCategorySuspendView(category: self.decorationsView.currentPage) //刷新左上角悬浮view
        }).disposed(by: disposeBag)
        
        // 使用装饰
        decorationOutput.decorationUpdateResult.drive(onNext: { [unowned self] (result) in
            switch result {
            case .success:
                let decorations = self.decorationsCategroyDict[self.decorationsView.currentPage]!
                decorations.filter({
                    $0.typeID == self.selectedDecoration.typeID && $0 != self.selectedDecoration
                }).map({
                    decorations.index(of: $0)
                }).forEach({ index in
                    guard let index = index else { return }
                    self.decorationsView.deselectItem(inPage: self.decorationsView.currentPage, atIndex: index)
                })
                self.updateCategorySuspendView(isUsing: true)
                DecorationControllerManager.shared.useDecoration(resourceID: self.selectedDecoration.resourceID)
                self.decorationCurrentUsingBehavior.onNext(())
                
            case let .fail(error):
                switch error {
                case .notUseDecorationInLowVIP:
                    BlockyAlert.show(title: R.string.localizable.notification(), message: R.string.localizable.vip_level_not_enough_then_payment(), showCancel: true).done(closure: { _ in
                        AppDelegate.globalServive().pushViewModel(VIPPaymentViewModel.self, params: nil, animated: true)
                    })
                default:
                    self.showAlert(withError: error)
                }
                self.selectedDecorationsDict.removeValue(forKey: self.selectedDecoration.typeID)
                // 如果失败，取消选中状态
                let decorations = self.decorationsCategroyDict[self.decorationsView.currentPage]!
                self.decorationsView.deselectItem(inPage: self.decorationsView.currentPage, atIndex: decorations.index(of: self.selectedDecoration)!)
            }
        }).disposed(by: disposeBag)
        
        // 卸下装饰
        decorationOutput.decorationDeleteResult.drive(onNext: {[unowned self] result in
            
            let decorations = self.decorationsCategroyDict[self.decorationsView.currentPage]! // 当前所在分类页的所有装饰
            
            switch result {
            case .success:
                if self.decorationsView.currentPage == 0 { // 在“当前正在使用”页卸下装饰，需要更新对应页的装饰状态
                    self.decorationsCategroyDict.filter {
                        let (_, decorations) = $0
                        return decorations.contains(self.selectedDecoration)
                        }.map { tuple -> (Int, Int)? in
                            let (category, decorations) = tuple
                            guard let index = decorations.index(of: self.selectedDecoration) else { return nil }
                            return (category, index)
                        }.forEach {
                            guard let (page, index) = $0 else {return}
                            self.decorationsView.deselectItem(inPage: page, atIndex: index)
                    }
                }else {
                    self.decorationsView.deselectItem(inPage: self.decorationsView.currentPage, atIndex: decorations.index(of: self.selectedDecoration)!)
                }
                self.updateCategorySuspendView(isUsing: false)
                DecorationControllerManager.shared.unuseDecoration(resourceID: self.selectedDecoration.resourceID)
                self.decorationCurrentUsingBehavior.onNext(())
                
            case let .fail(error):
                self.showAlert(withError: error)
                self.selectedDecorationsDict[self.selectedDecoration.typeID] = self.selectedDecoration
                // 如果失败，恢复选中状态
                self.decorationsView.selectItem(inPage: self.decorationsView.currentPage, atIndex: decorations.index(of: self.selectedDecoration)!)
            }
        }).disposed(by: disposeBag)
    }
    
    // MARK: 把当前有在使用的装饰 置为选中状态
    fileprivate func preSelectItems(inPage page: Int, atIndexes indexes: [Int?]) {
        indexes.forEach { [unowned self] index in
            guard let index = index else {
                return
            }
            self.decorationsView.selectItem(inPage: page, atIndex: index)
        }
    }
    
    // MARK: 更新当前正在使用的装饰
    fileprivate func updateCurrentUsingDecorations() {
        if decorationsCategroyDict[0] == nil {
            decorationCurrentUsingBehavior.onNext(())
        }
    }
    
    // MARK: 更新对应分类的装饰
    fileprivate func updateDecorations(category: Int) {
        if decorationsCategroyDict[category] == nil {
            decorationCategoryPublish.onNext(category)
        }
    }
    
    // MARK: 刷新左上角悬浮view
    fileprivate func refreshCategorySuspendView(category: Int) {
        let decorationViewModel = viewModel as! DecorationViewModel
        decorationCategorySuspendView.removeAllItems()
        decorationViewModel.categorySuspendViewContents(category: category, selectedDecorationsDict: selectedDecorationsDict) { [unowned self] contents in
            self.decorationCategorySuspendView.appendItems(contents: contents)
        }
    }
    
    // MARK: 刷新左上角悬浮view某个选项
    fileprivate func updateCategorySuspendView(isUsing: Bool) {
        let decorationViewModel = viewModel as! DecorationViewModel
        decorationViewModel.categorySuspendViewContent(selectedDecoration: selectedDecoration, isUsing: isUsing) { [unowned self] in
            let (content, index) = $0
            self.decorationCategorySuspendView.set(content: content, at: index) // 刷新某一个的内容
        }
    }
    
    // MARK: 根据装饰的URL去找对应的装饰
    fileprivate func fetchDecoration(ofThumbnailURLString URLString: String) -> DecorationEntity? {
        let decorationViewModel = viewModel as! DecorationViewModel
        return decorationViewModel.fetchDecoration(ofThumbnailURLString: URLString, in: selectedDecorationsDict)
    }
}

extension DecorationViewController: DecorationsViewDataSource, DecorationsViewDelegate {
    // MARK: DecorationsView 代理方法
    func decorationsView(_ decorationsView: DecorationsView, sizeForItemInPage page: Int, atIndex index: Int) -> CGSize {
        let width = (decorationsView.width - 3) / 4
        return CGSize(width: width, height: 119)
    }
    
    
    func decorationsView(_ decorationsView: DecorationsView, didBeginRefeshingInPage page: Int) {
        if page == 0 {
            decorationCurrentUsingBehavior.onNext(())
        }else {
            decorationCategoryPublish.onNext(page)
        }
    }
    
    func decorationsView(_ decorationsView: DecorationsView, didSelectItemInPage page: Int, atIndex index: Int) {
        DebugLog("选中 \(page)  \(index)")
        guard let decorations = decorationsCategroyDict[page] else { return }
        selectedDecoration = decorations[index]
        if selectedDecoration.resourceID == DecorationEntity.defaultVIPCrownResourceID { // 不是会员下，点击了灰色的皇冠
            BlockyAlert.show(title: R.string.localizable.notification(), message: R.string.localizable.vip_level_not_enough_then_payment(), showCancel: true).done(closure: { (_) in
                AppDelegate.globalServive().pushViewModel(VIPPaymentViewModel.self, params: nil, animated: true)
            })
            return
        }
        if page != 0 {
            selectedDecorationsDict[selectedDecoration.typeID] = selectedDecoration
        }
        decorationUpdtePublish.onNext(selectedDecoration.id)
    }
    
    func decorationsView(_ decorationsView: DecorationsView, didDeselectItemInPage page: Int, atIndex index: Int) {
//        DebugLog("取消选中 \(page)  \(index)")
        guard let decorations = decorationsCategroyDict[page] else { return }
        selectedDecoration = decorations[index]
        if page != 0 {
            selectedDecorationsDict.removeValue(forKey: selectedDecoration.typeID)
        }
        decorationDeletePublish.onNext(selectedDecoration.id)
    }
    
    func decorationsView(_ decorationsView: DecorationsView, didChangeTo page: Int) {
        if page == 0 {
            currentEquipmentButton.isSelected = true
            decorationMenu.selectedIndex = NSNotFound
            updateCurrentUsingDecorations()
        }else {
            currentEquipmentButton.isSelected = false
            decorationMenu.selectedIndex = page - 1
            updateDecorations(category: page)
        }
        self.refreshCategorySuspendView(category: page)
    }
    
    func decorationsViewWillBeginDecelerating(_ decorationsView: DecorationsView) {
        DecorationControllerManager.shared.suspendRendering()
    }
    
    func decorationsViewDidEndDecelerating(_ decorationsView: DecorationsView) {
        DecorationControllerManager.shared.resumeRendering()
    }
    
    func decorationsViewWillBeginDragging(_ decorationsView: DecorationsView) {
        DecorationControllerManager.shared.suspendRendering()
    }
    
    func decorationsViewDidEndDragging(_ decorationsView: DecorationsView) {
        DecorationControllerManager.shared.resumeRendering()
    }
    
    // MARK: DecorationsView 数据源方法
    func numberOfPages(in decorationsView: DecorationsView) -> Int {
        return 7
    }
    
    func decorationsView(_ decorationsView: DecorationsView, numberOfItemsInPage page: Int) -> Int {
        guard let decorationEntities = decorationsCategroyDict[page] else {
            return 0
        }
        return decorationEntities.count
    }
    
    func decorationsView(_ decorationsView: DecorationsView, reusableCompomentInPage page: Int, atIndex index: Int) -> DecorationReusableView.Type {
        return DecorationCompomentView.self
    }
    
    func decorationsView(_ decorationsView: DecorationsView, allowsRefreshingForPage page: Int) -> Bool {
        return true
    }
    
    func decorationsView(_ decorationsView: DecorationsView, contentForItemInPage page: Int, atIndex index: Int) -> Any? {
        guard let decorations = decorationsCategroyDict[page] else {
            return nil
        }
        return decorations[index]
    }
    
}

struct DecorationInput: ViewToViewModelInput {
    let decorationCategoryInput: Driver<Int>
    let decorationUpdateInput: Driver<Int>
    let decorationDeleteInput: Driver<Int>
    let decorationCurrentUsing: Driver<()>
    
    init(view: BaseViewController) {
        let decorationController = view as! DecorationViewController
        decorationCategoryInput = decorationController.decorationCategoryPublish.asDriver(onErrorJustReturn: 0)
        decorationUpdateInput = decorationController.decorationUpdtePublish.asDriver(onErrorJustReturn: 0)
        decorationDeleteInput = decorationController.decorationDeletePublish.asDriver(onErrorJustReturn: 0)
        decorationCurrentUsing = decorationController.decorationCurrentUsingBehavior.asDriver(onErrorJustReturn: ())
    }
}
