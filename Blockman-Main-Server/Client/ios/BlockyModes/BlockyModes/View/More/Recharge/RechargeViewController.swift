//
//  RechargeViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/16.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class RechargeViewController: BaseViewController {

    private weak var collectionView: UICollectionView?
    fileprivate var dataSource: [RechargeProductEntity] = []
    fileprivate let paymentManager = AppPaymentManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Recharge"
        
        let fileURL = Bundle.main.path(forResource: "rechargeProduct", ofType: ".json")!
        let productDicts = try! JSONSerialization.jsonObject(with: NSData.init(contentsOfFile: fileURL)! as Data, options: .allowFragments) as! [[String : Any]]
        dataSource = [RechargeProductEntity].deserialize(from: productDicts) as! [RechargeProductEntity]
        collectionView?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func createAndLayoutChildViews() {
        super.createAndLayoutChildViews()
        
        let shopBarButton = UIBarButtonItem(image: R.image.recharge_record()?.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
        shopBarButton.rx.tap.subscribe(onNext: { _ in
            AnalysisManager.trackEvent(AnalysisManager.Event.topup_info)
            AppDelegate.globalServive().pushViewModel(RechargeRecordViewModel.self, params: nil, animated: true)
        }).disposed(by: disposeBag)
        self.navigationItem.rightBarButtonItem = shopBarButton
        
        let propertyView = UserPropertyView(frame: .zero, showRecharge: false).addTo(superView: view).layout { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(50)
        }
        
        let tipLabel = UILabel().addTo(superView: view).configure { (label) in
            label.textColor = R.color.appColor._7a4e38()
            label.font = UIFont.size15
            label.text = NSLocalizedString("recharge_select_product", comment: "l 选择充值额度")
        }.layout { (make) in
            make.top.equalTo(propertyView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(margin_16)
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).addTo(superView: view).configure { (collectionView) in
            collectionView.register(cellForClass: RechargeCollectionViewCell.self)
            collectionView.backgroundColor = R.color.appColor._e7c99e()
            collectionView.dataSource = self
            collectionView.delegate = self
        }.layout { (make) in
            make.top.equalTo(tipLabel.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            collectionView!.snp.remakeConstraints({ make in
                make.top.equalToSuperview().offset(95)
                make.left.equalTo(view.safeAreaInsets.left)
                make.right.equalTo(view.safeAreaInsets.right)
                make.bottom.equalTo(view.safeAreaInsets.bottom)
            })
        }
    }
}

extension RechargeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as RechargeCollectionViewCell
        cell.configure(rechargeEntity: dataSource[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: margin_16, bottom: 20, right: margin_16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.width - 2 * margin_16 - 2) / 2
        return CGSize(width: width, height: width)
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if AccountStatusManager.shared.statusVariable.value == AccountStatusManager.Status.visit {
            BlockyAlert.show(title: R.string.localizable.notification(), message: R.string.localizable.recharge_after_login(), showCancel: true).done(closure: { _ in
                AppDelegate.globalServive().pushViewModel(AccountPageViewModel.self, params: AccountPageController.AccountType.login, animated: true)
            })
            return
        }
        
        if !AppPaymentManager.canMakePayment() {
            BlockyAlert.show(title: R.string.localizable.notification(), message: "Your device is not able or allowed to make payments")
            return
        }
        AnalysisManager.trackEvent(AnalysisManager.Event.topup_diamonds, parameters: ["diamondsID" : dataSource[indexPath.item].productId])
        paymentManager.pay(productID: dataSource[indexPath.item].productId)
    }
}
