//
//  IAPHandler.swift
//  TheBarCode
//
//  Created by Mac OS X on 29/11/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import StoreKit

class IAPHandler: NSObject {
    
    static var shared: IAPHandler = IAPHandler()
    
    typealias IAPHandlerCompletion = ((_ transactionIdentifier: String?, _ error: Error?) -> Void)
    
    var completionHandler: IAPHandlerCompletion?
    
    var isPurchaseInProgress: Bool = false
    
    func buyProductWithIdentifier(identifier: String, completion: @escaping IAPHandlerCompletion) {
        
        guard !self.isPurchaseInProgress else {
            let message = "One in app purchase is already in progress. Please wait while it is finished"
            let error = NSError(domain: "InPurchase", code: 100, userInfo: [NSLocalizedDescriptionKey : message])
            completion(nil, error)
            return
        }
        
        self.isPurchaseInProgress = true
        self.completionHandler = completion
        
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers: Set<String> = Set([identifier])
            let productRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
            productRequest.delegate = self
            productRequest.start()
        } else {
            let message = "Currently this device is not authorized to make payments. Please check your payment authorization settings and try again"
            let error = NSError(domain: "Unauthorized", code: 500, userInfo: [NSLocalizedDescriptionKey : message])
            self.completionHandler?(nil, error)
            self.isPurchaseInProgress = false
        }
    }
    
    func buyProduct(product: SKProduct, completion: @escaping IAPHandlerCompletion) {
        guard !self.isPurchaseInProgress else {
            let message = "One in app purchase is already in progress. Please wait while it is finished"
            let error = NSError(domain: "InPurchase", code: 100, userInfo: [NSLocalizedDescriptionKey : message])
            completion(nil, error)
            return
        }
        
        self.isPurchaseInProgress = true
        self.completionHandler = completion
        
        self.buyProduct(product: product)
    }
    
    private func buyProduct(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
}

//MARK: SKProductsRequestDelegate, SKPaymentTransactionObserver
extension IAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            self.buyProduct(product: product)
        } else {
            let message = "No valid product found for the provided product identifier"
            let error = NSError(domain: "ProductNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey : message])
            self.completionHandler?(nil, error)
            self.isPurchaseInProgress = false
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.completionHandler?(nil, error)
        self.isPurchaseInProgress = false
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for trans in transactions {
            switch trans.transactionState {
            case .purchased:
                debugPrint("Product Purchased");
                SKPaymentQueue.default().finishTransaction(trans)
                SKPaymentQueue.default().remove(self)
                self.completionHandler?(trans.transactionIdentifier!, nil)
                self.isPurchaseInProgress = false
                break;
            case .failed:
                debugPrint("Purchased Failed");
                SKPaymentQueue.default().finishTransaction(trans)
                SKPaymentQueue.default().remove(self)
                self.completionHandler?(nil, trans.error)
                self.isPurchaseInProgress = false
                break;
            case .restored:
                debugPrint("Already Purchased");
                SKPaymentQueue.default().restoreCompletedTransactions()
                SKPaymentQueue.default().remove(self)
                self.completionHandler?(trans.transactionIdentifier!, nil)
                self.isPurchaseInProgress = false
            default:
                break;
            }
        }
    }
}
