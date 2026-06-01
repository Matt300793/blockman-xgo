//
//  DecorationShopViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/9.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import BlockModsGameKit
import SnapKit
import RxSwift
import RxCocoa

class DecorationShopViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return DecorationShopInput.self}
    
    fileprivate weak var decorationMenu: DecorationMenu!
    fileprivate weak var decorationsView: DecorationsView!
    fileprivate weak var decorationCategorySuspendView: DecorationCategorySuspendView!
    fileprivate weak var decorationCurrencyMaskView: DecorationShopCurrencyMaskView!
    fileprivate weak var upDownView: UIButton?
    fileprivate weak var shoppingCartButton: UIButton?
    fileprivate weak var diamondTotalPriceView: UIButton?
    fileprivate weak var goldTotalPriceView: UIButton?
    fileprivate weak var decorationMenuContainView: UIView?
    private var menuToPropertyViewConstraint: Constraint!
    
    fileprivate var decorationCategoryPublish: PublishSubject<Int> = PublishSubject() // 装饰种类
    fileprivate var decorationNextPageBehavior = BehaviorSubject(value: 0) // 当前所在分类页的上拉加载更多页码
    fileprivate var decorationsCategroyDict: [Int : [DecorationShopEntity]] = [:] // 外层存着每个分类对应的装饰，内层存着价格币种对应的装饰
    fileprivate var selectedDecorationsDict: [Int : DecorationShopEntity] = [:] // key: typeID
    private var totalDiamondPrice: Int = 0
    private var totalGoldPrice: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 原先采用按需加载，但涉及到币种切换及各种逻辑，处理起来蛋疼..
        // 所以先这样一次性加载所有，之后本地操作数据
        for category in 1...5 {
            self.decorationCategoryPublish.onNext(category)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        DecorationControllerManager.shared.add(toParent: self, layout: { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(50)
            make.height.equalTo(DecorationControllerManager.decorationControllerHeight)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DecorationControllerManager.shared.removeFromParent()
    }
    
    override func createAndLayoutChildViews() {
        
        // 顶部财产view
        let topPropertyView = UserPropertyView(frame: .zero).addTo(superView: view).layout { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        decorationCategorySuspendView = DecorationCategorySuspendView(items: []).addTo(superView: view).layout { (make) in
            make.top.equalTo(topPropertyView.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(margin_14)
            make.size.equalTo(CGSize(width: 45, height: 195))
        }
        decorationCategorySuspendView.rx.controlEvent(.valueChanged).asDriver().filter {[unowned self] in
            self.decorationCategorySuspendView.selectedImageURLString != nil
            }.drive(onNext: { [unowned self] in
                if let decoration = self.fetchDecoration(ofThumbnailURLString: self.decorationCategorySuspendView.selectedImageURLString!), let allDecorationsInPage = self.decorationsCategroyDict[self.decorationsView.currentPage + 1] { // 取消当前选中的装饰
                    let decorations = self.decorationsForCurrentCurrency(inPageAllDecorations: allDecorationsInPage)
                    guard let index = decorations.index(of: decoration) else {return}
                    self.decorationsView.deselectItem(inPage: self.decorationsView.currentPage, atIndex: index)
                    self.selectedDecorationsDict.removeValue(forKey: decoration.typeID)
                    self.refreshShoppingCart()
                }
            }).disposed(by: disposeBag)
        
        shoppingCartButton = UIButton().addTo(superView: view).configure { (button) in
            button.setBackgroundImage(R.image.decorationshop_shoppingcart(), for: .normal)
            button.setBackgroundImage(R.image.decorationshop_shoppingcart_disable(), for: .disabled)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
//            button.setTitle(NSLocalizedString("shop_cart", comment: "shop_cart"), for: .normal)
            button.titleLabel?.font = UIFont.size15
            button.setTitleColor(UIColor.white, for: .normal)
            button.isEnabled = false
        }.layout { (make) in
            make.right.equalToSuperview().offset(-margin_12)
            make.top.equalTo(topPropertyView.snp.bottom).offset(DecorationControllerManager.decorationControllerHeight - 60)
            make.size.equalTo(CGSize(width: 100, height: 30))
        }
        // 购物车按钮点击跳转到购物车界面
        shoppingCartButton!.rx.tap.asDriver().drive(onNext: { [unowned self] in
            if AccountStatusManager.shared.statusVariable.value == .visit {
                BlockyAlert.show(title: R.string.localizable.notification(), message: R.string.localizable.recharge_after_login(), showCancel: true).done(closure: { _ in
                    AppDelegate.globalServive().pushViewModel(AccountPageViewModel.self, params: AccountPageController.AccountType.login, animated: true)
                })
                return
            }
            let payingDecorations = self.selectedDecorationsDict.map({ $0.1 })
            AnalysisManager.trackEvent(AnalysisManager.Event.click_Cart)
            AppDelegate.globalServive().pushViewModel(DecorationShoppingCartViewModel.self, params: (self.totalGoldPrice, self.totalDiamondPrice, payingDecorations), animated: true)
        }).disposed(by: disposeBag)
        
        let priceViewConfig = { (button: UIButton) in
            button.isUserInteractionEnabled = false
            button.titleLabel?.font = UIFont.size13
            button.backgroundColor = UIColor.red.withAlphaComponent(0.35)
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitleColor(UIColor.red, for: .disabled)
            button.setTitle("0", for: .normal)
            button.contentHorizontalAlignment = .left
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        diamondTotalPriceView = UIButton().addTo(superView: view).configure(priceViewConfig).configure { (priceView) in
            priceView.setImage(R.image.common_diamond(), for: .normal)
        }.layout { [unowned self] (make) in
            make.right.equalToSuperview().offset(-margin_16)
            make.bottom.equalTo(self.shoppingCartButton!.snp.top).offset(-margin_10)
            make.width.greaterThanOrEqualTo(90)
        }
        
        goldTotalPriceView = UIButton().addTo(superView: view).configure(priceViewConfig).configure { (priceView) in
            priceView.setImage(R.image.common_gold(), for: .normal)
            }.layout {[unowned self] (make) in
                make.right.equalToSuperview().offset(-margin_16)
                make.bottom.equalTo(self.diamondTotalPriceView!.snp.top).offset(-margin_10)
                make.width.greaterThanOrEqualTo(90)
        }
        
        decorationMenuContainView = UIView().addTo(superView: view).layout {[unowned self] (make) in
            make.left.right.equalToSuperview()
            self.menuToPropertyViewConstraint = make.top.equalTo(topPropertyView.snp.bottom).offset(DecorationControllerManager.decorationControllerHeight).constraint
            make.height.equalTo(50)
        }
        
        upDownView = UIButton().addTo(superView: decorationMenuContainView!).configure { (button) in
            button.setBackgroundImage(R.image.decorationshop_up(), for: .normal)
            button.setBackgroundImage(R.image.decorationshop_down(), for: .selected)
        }.layout { (make) in
            make.left.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        upDownView!.rx.tap.map { [unowned self] _ -> Bool in
            !self.upDownView!.isSelected
        }.subscribe(onNext: { [unowned self] in
            self.updateMenuConstraint(isUp: $0)
        }).disposed(by: disposeBag)
        
        let priceTypeView = UIButton().addTo(superView: decorationMenuContainView!).configure { (view) in
            view.titleLabel?.font = UIFont.size15
            view.setTitleColor(R.color.appColor._555555(), for: .normal)
            view.setTitle("▾", for: .normal)
            view.titleEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
            view.setBackgroundImage(R.image.decorationshop_all(), for: .normal)
        }.layout { [unowned self] (make) in
            make.right.centerY.equalToSuperview()
            make.size.equalTo(self.upDownView!.snp.size)
        }
        priceTypeView.rx.tap.subscribe(onNext: { [unowned self] in
            self.decorationCurrencyMaskView.isHidden = !self.decorationCurrencyMaskView.isHidden
        }).disposed(by: disposeBag)
        
        decorationMenu = DecorationMenu().addTo(superView: decorationMenuContainView!).configure({ (menu) in
            menu.selectedIndex = 0
        }).layout { [unowned self] (make) in
            make.left.equalTo(self.upDownView!.snp.right)
            make.right.equalTo(priceTypeView.snp.left)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        decorationMenu.rx.controlEvent(.valueChanged).asDriver().drive(onNext: {[unowned self] in
            DebugLog("点击了collectionview menu index \(self.decorationMenu.selectedIndex)")
            self.decorationsView.setCurrentPage(self.decorationMenu.selectedIndex, animated: false)
        }).disposed(by: disposeBag)
        
        decorationsView = DecorationsView().addTo(superView: view).configure { (view) in
            view.dataSource = self
            view.delegate = self
        }.layout { [unowned self] (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.decorationMenuContainView!.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        decorationCurrencyMaskView = DecorationShopCurrencyMaskView().addTo(superView: decorationsView).configure({ (maskView) in
            maskView.isHidden = true
        }).layout(snapKitMaker: { (make) in
            make.edges.equalToSuperview()
        })
        decorationCurrencyMaskView.rx.controlEvent(.valueChanged).subscribe(onNext: { [unowned self] in
            self.decorationCurrencyMaskView.isHidden = true
            switch self.decorationCurrencyMaskView.selectedCurrency {
            case DecorationShopCurrencyMaskView.Currency.diamond:
                priceTypeView.setBackgroundImage(R.image.decorationshop_diamond(), for: .normal)
            case DecorationShopCurrencyMaskView.Currency.gold:
                priceTypeView.setBackgroundImage(R.image.decorationshop_gold(), for: .normal)
            default:
                priceTypeView.setBackgroundImage(R.image.decorationshop_all(), for: .normal)
            }
            // 切换币种时，刷新所有页..
            self.decorationsView.deselectAllPageItems()
            self.decorationsView.reloadDataForAllPages()
            for (key, decorations) in self.decorationsCategroyDict {
                let currencyDecorations = self.decorationsForCurrentCurrency(inPageAllDecorations: decorations)
                let indexes: [Int] = []
                currencyDecorations.reduce(into: indexes, { (indexes, decoration) in
                    if let selectedDecoration = self.selectedDecorationsDict[decoration.typeID] {
                        if selectedDecoration == decoration {
                            indexes.append(currencyDecorations.index(of: decoration)!)
                        }
                    }
                }).forEach({
                    self.decorationsView.selectItem(inPage: key - 1, atIndex: $0)
                })
            }
        }).disposed(by: disposeBag)
    }
    
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            decorationsView.snp.remakeConstraints({ (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(self.decorationMenuContainView!.snp.bottom)
                make.bottom.equalToSuperview().inset(view.safeAreaInsets.bottom)
            })
        }
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let decorationShopOutput = output as! DecorationShopOutput
        
        decorationShopOutput.decorationsOfCategory.drive(onNext: { [unowned self] decorationsCateDict in
            let key = decorationsCateDict.keys.first!
            DebugLog("viewModelOutputDrive-------\(key)")
            if var decorations = self.decorationsCategroyDict[key] {
                decorations.append(contentsOf: decorationsCateDict[key]!)
                self.decorationsCategroyDict[key] = decorations
            }else {
                self.decorationsCategroyDict[key] = decorationsCateDict[key]!
            }
            if key - 1 == 0 {
                self.refreshCategorySuspendView(page: 0)
            }
            self.decorationsView.reloadData(forPage: key - 1)
            guard !self.decorationsCategroyDict[key]!.isEmpty else {
                self.decorationsView.showHolderViewWhenErrorOrEmpty(inPage: key - 1)
                return
            }
            self.decorationsView.dismissHolderView(inPage: key - 1)
        }).disposed(by: disposeBag)
    }
    
    // MARK: 获取当前所选币种的装饰
    fileprivate func decorationsForCurrentCurrency(inPageAllDecorations allDecorations: [DecorationShopEntity]) -> [DecorationShopEntity] {
        
        if decorationCurrencyMaskView.selectedCurrency == DecorationShopCurrencyMaskView.Currency.all { // 当前为所有币种情况
            return allDecorations
        }else { // 钻石或金币
            return allDecorations.filter { $0.priceType.rawValue == decorationCurrencyMaskView.selectedCurrency.rawValue }
        }
    }
    
    // MARK: 刷新左上角悬浮view
    fileprivate func refreshCategorySuspendView(page: Int) {
        let decorationShopViewModel = viewModel as! DecorationShopViewModel
        decorationCategorySuspendView.removeAllItems()
        decorationShopViewModel.categorySuspendViewContents(category: page + 1, selectedDecorationsDict: selectedDecorationsDict) { [unowned self] (contents) in
            self.decorationCategorySuspendView.appendItems(contents: contents)
        }
    }
    
    // MARK: 刷新左上角悬浮view某个选项
    fileprivate func updateCategorySuspendView(isUsing: Bool, selectedDecoration: DecorationShopEntity) {
        let decorationShopViewModel = viewModel as! DecorationShopViewModel
        decorationShopViewModel.categorySuspendViewContent(selectedDecoration: selectedDecoration, isUsing: isUsing) { [unowned self] in
            let (content, index) = $0
            self.decorationCategorySuspendView.set(content: content, at: index) // 刷新某一个的内容
        }
    }
    
    // MARK: 根据装饰的URL去找对应的装饰
    fileprivate func fetchDecoration(ofThumbnailURLString URLString: String) -> DecorationShopEntity? {
        let decorationShopViewModel = viewModel as! DecorationShopViewModel
        return decorationShopViewModel.fetchDecoration(ofThumbnailURLString: URLString, in: selectedDecorationsDict)
    }
    
    fileprivate func updateMenuConstraint(isUp: Bool) {
        if isUp {
            self.menuToPropertyViewConstraint.update(offset: 0)
        }else {
            self.menuToPropertyViewConstraint.update(offset: DecorationControllerManager.decorationControllerHeight)
        }
        UIView.animate(withDuration: 0.35, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.upDownView?.isSelected = isUp
        }
    }
    
    fileprivate func refreshShoppingCart() {
        let shopViewModel = viewModel as! DecorationShopViewModel
        totalGoldPrice = shopViewModel.calculateTotalGoldPrice(in: selectedDecorationsDict)
        goldTotalPriceView?.setTitle(String(totalGoldPrice), for: .normal)
        goldTotalPriceView?.isEnabled = totalGoldPrice <= AccountPropertyManager.shared.golds.value
        
        totalDiamondPrice = shopViewModel.calculateTotalDiamondPrice(in: selectedDecorationsDict)
        diamondTotalPriceView?.setTitle(String(totalDiamondPrice), for: .normal)
        diamondTotalPriceView?.isEnabled = totalDiamondPrice <= AccountPropertyManager.shared.diamonds.value
        
        shoppingCartButton?.isEnabled = selectedDecorationsDict.keys.count != 0 && (totalGoldPrice != 0 || totalDiamondPrice != 0)
    }
}


extension DecorationShopViewController: DecorationsViewDataSource, DecorationsViewDelegate {
    func numberOfPages(in decorationsView: DecorationsView) -> Int {
        return 6
    }
    
    func decorationsView(_ decorationsView: DecorationsView, numberOfItemsInPage page: Int) -> Int {
        guard let decorationEntities = decorationsCategroyDict[page + 1] else {
            decorationsView.showHolderViewWhenErrorOrEmpty(inPage: page)
            return 0
        }
        
        let number = decorationsForCurrentCurrency(inPageAllDecorations: decorationEntities).count
        number == 0 ? decorationsView.showHolderViewWhenErrorOrEmpty(inPage: page) : decorationsView.dismissHolderView(inPage: page)
        return number
    }
    
    func decorationsView(_ decorationsView: DecorationsView, reusableCompomentInPage page: Int, atIndex index: Int) -> DecorationReusableView.Type {
        return DecorationShopCompomentView.self
    }
    
    func decorationsView(_ decorationsView: DecorationsView, contentForItemInPage page: Int, atIndex index: Int) -> Any? {
        
        guard let decorations = decorationsCategroyDict[page + 1] else {
            return nil
        }
        
        return decorationsForCurrentCurrency(inPageAllDecorations: decorations)[index]
    }
    
    func decorationsView(_ decorationsView: DecorationsView, sizeForItemInPage page: Int, atIndex index: Int) -> CGSize {
        let width = (decorationsView.width - 3) / 4
        return CGSize(width: width, height: 119)
    }
    
    func decorationsView(_ decorationsView: DecorationsView, didChangeTo page: Int) {
        decorationMenu.selectedIndex = page
        refreshCategorySuspendView(page: page)
    }
    
    func decorationsView(_ decorationsView: DecorationsView, didSelectItemInPage page: Int, atIndex index: Int) {
        DebugLog("选中 \(page)  \(index)")
        guard let allDecorations = decorationsCategroyDict[page + 1] else { return }
        
        let currentDecorations = decorationsForCurrentCurrency(inPageAllDecorations: allDecorations)
        let selectedDecoration = currentDecorations[index] // 当前选中装饰
        
        // 取消同种类的装饰选中状态
        currentDecorations.filter({
            $0.typeID == selectedDecoration.typeID && $0 != selectedDecoration
        }).map({
            currentDecorations.index(of: $0)
        }).forEach({ index in
            guard let index = index else { return }
            self.decorationsView.deselectItem(inPage: page, atIndex: index)
        })
        
        upDownView!.isSelected ? updateMenuConstraint(isUp: false) : ()
        selectedDecorationsDict[selectedDecoration.typeID] = selectedDecoration
        refreshShoppingCart()
        updateCategorySuspendView(isUsing: true, selectedDecoration: selectedDecoration)
        DecorationControllerManager.shared.useDecoration(resourceID: selectedDecoration.resourceID)
    }
    
    func decorationsView(_ decorationsView: DecorationsView, didDeselectItemInPage page: Int, atIndex index: Int) {
        DebugLog("取消选中 \(page)  \(index)")
        guard let allDecorations = decorationsCategroyDict[page + 1] else { return }
        
        let selectedDecoration = decorationsForCurrentCurrency(inPageAllDecorations: allDecorations)[index]
        selectedDecorationsDict.removeValue(forKey: selectedDecoration.typeID)
        refreshShoppingCart()
        updateCategorySuspendView(isUsing: false, selectedDecoration: selectedDecoration)
        DecorationControllerManager.shared.unuseDecoration(resourceID: selectedDecoration.resourceID)
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
}

struct DecorationShopInput: ViewToViewModelInput {
    let decorationCategoryInput: Driver<Int>
    let decorationNextPageInput: Driver<Int>
    
    init(view: BaseViewController) {
        let decorationShopController = view as! DecorationShopViewController
        decorationCategoryInput = decorationShopController.decorationCategoryPublish.asDriver(onErrorJustReturn: 1)
        decorationNextPageInput = decorationShopController.decorationNextPageBehavior.asDriver(onErrorJustReturn: 0)
    }
}
