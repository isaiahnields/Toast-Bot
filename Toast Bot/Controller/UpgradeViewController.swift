//
//  SettingsViewController.swift
//  Toast Bot
//
//  Created by isaiahnields on 6/21/20.
//  Copyright © 2020 com.isaiahnields. All rights reserved.
//

import UIKit
import StoreKit

class UpgradeViewController: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {

    var toastBotPro: SKProduct?
    
    @IBOutlet var goProButton: GradientButton!
    @IBOutlet var activityView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goProButton.clipsToBounds = true
        
        activityView.isHidden = true
        activityView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityView)
        self.view.bringSubviewToFront(activityView)
        activityView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        activityView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityView.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
        activityView.widthAnchor.constraint(equalToConstant: 200.0).isActive = true

        fetchProducts()
        
        SKPaymentQueue.default().add(self)
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func pressGoPro(_ sender: GradientButton) {
        if SKPaymentQueue.canMakePayments() {
            showActivityIndicator()
            let paymentRequest = SKPayment(product: toastBotPro!)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(paymentRequest)
        }
    }
    
    @IBAction func restorePurchase(_ sender: UIButton) {
        showActivityIndicator()
        self.view.isUserInteractionEnabled = false
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: ["isaiahnields.ToastBot.Pro"])
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            toastBotPro = product
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                UserDefaults.standard.set(true, forKey: "isaiahnields.ToastBot.Pro")
                hideActivityIndicator()
                hideProButton()
                self.dismiss(animated: true)
            }
            else if transaction.transactionState == .failed {
                hideActivityIndicator()
                if let error = transaction.error {
                    print(error.localizedDescription)
                }
            }
            else if transaction.transactionState == .restored {
                SKPaymentQueue.default().finishTransaction(transaction)
                UserDefaults.standard.set(true, forKey: "isaiahnields.ToastBot.Pro")
                hideActivityIndicator()
                hideProButton()
                self.dismiss(animated: true)
            }
        }
    }
    
    func showActivityIndicator() {
        self.activityView.isHidden = false
    }
    
    func hideActivityIndicator() {
        self.activityView.isHidden = true
    }
    
    func hideProButton() {
        let homeViewController = UIApplication.shared.windows[0].rootViewController as! HomeViewController
        homeViewController.proButton.isHidden = true
    }
}
