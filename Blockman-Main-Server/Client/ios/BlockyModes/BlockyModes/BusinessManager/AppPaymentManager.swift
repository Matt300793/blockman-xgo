//
//  AppPaymentManager.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/16.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import StoreKit
import RxSwift

class AppPaymentManager: NSObject {
    
    fileprivate var productID: String!
    fileprivate let disposeBag = DisposeBag()
    
    public class func canMakePayment() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    public func pay(productID: String) {
        
        BlockyHUD.showLoading(inView: AppDelegate.keyWindow())
        
        self.productID = productID
        
        let productSet: Set<String> = [productID]
        let productRequest = SKProductsRequest(productIdentifiers: productSet)
        productRequest.delegate = self
        productRequest.start()
    }
}

extension AppPaymentManager: SKPaymentTransactionObserver, SKProductsRequestDelegate {
    // MARK: SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        let products = response.products
        if products.isEmpty {
            BlockyHUD.showText(R.string.localizable.apppurchase_product_request_fail(), inView: AppDelegate.keyWindow())
            return;
        }
        
        let filterProducts = products.filter { [unowned self] in
            $0.productIdentifier == self.productID
        }
        guard !filterProducts.isEmpty else {return}
        
        let payment = SKPayment(product: filterProducts[0])
        SKPaymentQueue.default().add(payment) // 添加到队列
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        
        AnalysisManager.trackEvent(AnalysisManager.Event.topup_request_product_failed)
        BlockyHUD.showText(R.string.localizable.apppurchase_product_request_fail(), inView: AppDelegate.keyWindow())
    }
    
    // MARK: SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break
                
            case .purchased:
                if let receiptString = readUnverifyReceiptString(forTransaction: transaction) {
                    BlockyHUD.showLoading(withText: R.string.localizable.apppurchase_resolve_unfinished_transaction(), inView: AppDelegate.keyWindow())
                    verifyTransaction(transaction, receipt: receiptString)
                }else {
                    let data = try! Data.init(contentsOf: Bundle.main.appStoreReceiptURL!)
                    let receiptString = data.base64EncodedString()
                    storeUnverifyTransaction(transaction, receipt: receiptString)
                    verifyTransaction(transaction, receipt: receiptString)
                }
                
            case .restored:
                BlockyHUD.hide(forView: AppDelegate.keyWindow())
                restoredTransaction(transaction)
                
            case .failed:
                AnalysisManager.trackEvent(AnalysisManager.Event.topup_dia_cancel_pay)
                BlockyHUD.showText(R.string.localizable.decoration_pay_failed(), inView: AppDelegate.keyWindow())
                failedTransaction(transaction)
                
            default:
                break
            }
        }
    }
}


extension AppPaymentManager {
    
    fileprivate func storeUnverifyTransaction(_ transaction: SKPaymentTransaction?, receipt: String?) {
        guard let receipt = receipt, let transaction = transaction else { return }
        
        let data = try? JSONSerialization.data(withJSONObject: [transaction.transactionIdentifier! : receipt], options: .prettyPrinted)
        BlockyUserDefaults.storeData(data, forKey: BlockyUserDefaults.unverifyTransactionKey)
    }
    
    fileprivate func readUnverifyReceiptString(forTransaction transaction: SKPaymentTransaction) -> String? {
        let data = BlockyUserDefaults.data(forKey: BlockyUserDefaults.unverifyTransactionKey)
        guard let cacheData = data else { return nil }
        
        let cacheDict = try? JSONSerialization.jsonObject(with: cacheData, options: .allowFragments)
        guard let receiptDict = cacheDict as? [String : String] else { return nil }
        
        return receiptDict[transaction.transactionIdentifier!]
    }
    
    fileprivate func failedTransaction(_ transaction: SKPaymentTransaction) {
        finishTransaction(transaction)
        BlockyUserDefaults.removeValue(forKey: BlockyUserDefaults.unverifyTransactionKey)
    }
    
    fileprivate func restoredTransaction(_ transaction: SKPaymentTransaction) {
        finishTransaction(transaction)
        BlockyUserDefaults.removeValue(forKey: BlockyUserDefaults.unverifyTransactionKey)
    }
    
    fileprivate func finishTransaction(_ transaction: SKPaymentTransaction) {
        guard transaction.transactionState != .purchasing else {
            return
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    fileprivate func verifyTransaction(_ transaction: SKPaymentTransaction, receipt: String) {
        
        RechargeNetServer.verify(transactionID: transaction.transactionIdentifier!, receiptString: receipt)
        .map({ response -> [String : Int] in
            response["data"] as! [String : Int]
        })
        .subscribe(onSuccess: { [unowned self] in
            DebugLog($0)
            self.finishTransaction(transaction)
            AnalysisManager.trackEvent(AnalysisManager.Event.topup_dia_suc, parameters: ["diamondsID" : transaction.transactionIdentifier ?? ""])
            AccountPropertyManager.shared.updateDiamonds($0["diamonds"]!) // 更新钻石数
            BlockyHUD.showSuccess(text: R.string.localizable.decoration_pay_successful(), inView: AppDelegate.keyWindow())
            BlockyUserDefaults.removeValue(forKey: BlockyUserDefaults.unverifyTransactionKey)
        }) { (error) in
            DebugLog(error)
            BlockyHUD.showText(R.string.localizable.decoration_pay_failed(), inView: AppDelegate.keyWindow())
            if (error as! BlockyError) == BlockyError.transactionHasVerified {
                self.finishTransaction(transaction)
                BlockyUserDefaults.removeValue(forKey: BlockyUserDefaults.unverifyTransactionKey)
            }
        }.disposed(by: disposeBag)
    }
}
