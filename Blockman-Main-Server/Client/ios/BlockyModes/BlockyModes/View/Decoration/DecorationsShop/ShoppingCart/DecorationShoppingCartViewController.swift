//
//  DecorationShoppingCartViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/15.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DecorationShoppingCartViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return DecorationShoppingCartInput.self}
    
    private var totalGoldPrice: Int = 0
    private var totalDiamondPrice: Int = 0
    private weak var originPriceLabel: UILabel?
    private weak var discountPriceLabel: UILabel?
    private weak var tableView: UITableView?
    private var bottomPayView: UIView?
    fileprivate var decorations: [DecorationShopEntity] = []
    fileprivate var decorationIDsPublish: PublishSubject<[Int]> = PublishSubject()
    fileprivate let presentAnimation = PresentAnimation()
    fileprivate let dismissAnimation = DismissAnimation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let (totalGoldPrice, totalDiamondPrice, decorations) = params as! (Int, Int, [DecorationShopEntity])
        switch AccountInfoManager.shared.vip.value {
        case 2:
            self.totalGoldPrice = totalGoldPrice * 9 / 10
            self.totalDiamondPrice = totalDiamondPrice * 9 / 10
        case 3:
            self.totalGoldPrice = totalGoldPrice * 8 / 10
            self.totalDiamondPrice = totalDiamondPrice * 8 / 10
        default:
            self.totalGoldPrice = totalGoldPrice
            self.totalDiamondPrice = totalDiamondPrice
        }
        self.decorations = decorations
        tableView?.reloadData()
        
        let shopCartViewModel = viewModel as! DecorationShoppingCartViewModel
        originPriceLabel?.attributedText = shopCartViewModel.originPriceAttributedText(golds: totalGoldPrice, diamons: totalDiamondPrice)
        discountPriceLabel?.attributedText = shopCartViewModel.discountPriceAttributedText(golds: self.totalGoldPrice, diamons: self.totalDiamondPrice)
    }
    
    override func createAndLayoutChildViews() {
        
        let propertyView = UserPropertyView(frame: .zero).addTo(superView: view).layout { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        let bottomPayView = UIView().addTo(superView: view).configure { (view) in
            view.backgroundColor = R.color.appColor._f6edd2()
        }.layout { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(140)
        }
        self.bottomPayView = bottomPayView

        originPriceLabel = UILabel().addTo(superView: bottomPayView).layout(snapKitMaker: { (make) in
            make.right.equalToSuperview().offset(-margin_12)
            make.top.equalToSuperview().offset(12)
        }).configure({ (label) in
            label.textAlignment = .right
        })
        
        discountPriceLabel = UILabel().addTo(superView: bottomPayView).layout(snapKitMaker: { (make) in
            make.right.equalToSuperview().offset(-margin_12)
            make.top.equalTo(originPriceLabel!.snp.bottom).offset(16)
        }).configure({ (label) in
            label.textAlignment = .right
        })
        
        let payButton = UIButton().addTo(superView: bottomPayView).configure { (button) in
            button.backgroundColor = R.color.appColor._d62121()
            button.titleLabel?.font = UIFont.size15
            button.setTitle(NSLocalizedString("confirm_payment", comment: "确认付款"), for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.layer.cornerRadius = 4
        }.layout { (make) in
            make.left.right.equalToSuperview().inset(margin_12)
            make.height.equalTo(40)
            make.top.equalTo(discountPriceLabel!.snp.bottom).offset(16)
        }
        payButton.rx.tap.asDriver().drive(onNext: { [unowned self] in
            if AccountStatusManager.shared.statusVariable.value == AccountStatusManager.Status.visit {
                BlockyAlert.show(title: R.string.localizable.notification(), message: R.string.localizable.no_permission())
                return
            }
            
            AnalysisManager.trackEvent(AnalysisManager.Event.click_Confirm_Payment)
            self.decorationIDsPublish.onNext(self.decorations.map({ $0.id }))
        }).disposed(by: disposeBag)
        
        tableView = UITableView(frame: .zero, style: .plain).addTo(superView: view).configure { (tableView) in
            tableView.backgroundColor = UIColor.clear
            tableView.bounces = false
            tableView.separatorStyle = .none
            tableView.dataSource = self
            tableView.delegate = self
            tableView.rowHeight = 90
            tableView.register(cellForClass: DecorationShoppingCartTableCell.self)
        }.layout { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(propertyView.snp.bottom)
            make.bottom.equalTo(bottomPayView.snp.top)
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11, *) {
            self.bottomPayView!.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().inset(view.safeAreaInsets.bottom)
                make.height.equalTo(115)
            }
        }
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let shopCartOutput = output as! DecorationShoppingCartOutput
        shopCartOutput.purchaseResult.drive(onNext: { [unowned self] tuple in
            let (diamondsNeed, goldsNeed, failProductIDs) = tuple
            if diamondsNeed == 0, goldsNeed == 0, failProductIDs.isEmpty {  // 购买成功
                AccountPropertyManager.shared.decrease(diamonds: self.totalDiamondPrice, golds: self.totalGoldPrice)
                BlockyAlert.show(title: R.string.localizable.notification(), message: NSLocalizedString("decoration_pay_successful", comment: "购买成功")).done(closure: { [unowned self] _ in
                    AnalysisManager.trackEvent(AnalysisManager.Event.buy_Dress_Suc, parameters: ["decorations" : self.decorations.map({$0.resourceID}).joined(separator: " ")])
                    AppDelegate.globalServive().popToRootViewModel(animated: true)
                })
                return
            }
            
            var balanceNotEnough = ""
            var showAds = false
            if diamondsNeed > 0 {
                showAds = true
                AnalysisManager.trackEvent(AnalysisManager.Event.buy_Dress_Failed, parameters: ["message" : "魔方不足"])
                balanceNotEnough.append(String(format: NSLocalizedString("diamonds_not_enough", comment: "魔方不足"), diamondsNeed))
            }
            if goldsNeed > 0 {
                showAds = true
                AnalysisManager.trackEvent(AnalysisManager.Event.buy_Dress_Failed, parameters: ["message" : "金币不足"])
                balanceNotEnough.append("\n")
                balanceNotEnough.append(String(format: NSLocalizedString("golds_not_enough", comment: "金币不足"), goldsNeed))
            }
            if !balanceNotEnough.isEmpty {
                AppDelegate.globalServive().presentViewModel(InsufficientBalanceViewModel.self, params: showAds, animated: true, completion: nil)
                return
            }
            
            AnalysisManager.trackEvent(AnalysisManager.Event.buy_Dress_Failed, parameters: ["message" : "限购商品卖完或者部分商品购买失败"])
            BlockyAlert.show(title: R.string.localizable.notification(), message: R.string.localizable.decoration_pay_failed())
        })
        .disposed(by: disposeBag)
    }
}

extension DecorationShoppingCartViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decorations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as DecorationShoppingCartTableCell
        cell.configure(shopEntity: decorations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView().configure { (view) in
            view.height = 30
            view.backgroundColor = R.color.appColor._e7c99e()
        }
        let label = UILabel()
        label.font = UIFont.size13
        label.textColor = R.color.appColor._644d22()
        label.text = NSLocalizedString("decoration_bill", comment: "服装账单")
        label.sizeToFit()
        label.x = margin_12
        label.centerY = view.height * 0.5
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}

extension DecorationShoppingCartViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimation
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimation
    }
}

struct DecorationShoppingCartInput: ViewToViewModelInput {
    let decorationIDsInput: Driver<[Int]>
    
    init(view: BaseViewController) {
        let shopCartController = view as! DecorationShoppingCartViewController
        decorationIDsInput = shopCartController.decorationIDsPublish.asDriver(onErrorJustReturn: [])
    }
}
