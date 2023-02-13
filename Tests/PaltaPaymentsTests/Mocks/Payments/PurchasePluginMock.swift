//
//  PurchasePluginMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.05.2022.
//

import Foundation
import PaltaPayments

final class PurchasePluginMock: PurchasePlugin {
    var delegate: PurchasePluginDelegate?
    
    var logInUserId: UserId?
    var logInCompletion: ((Result<(), Error>) -> Void)?
    var logOutCalled = false
    var getProductsIndentifiers: [String]?
    var getPaidFeaturesCompletion: ((Result<PaidFeatures, Error>) -> Void)?
    var getProductsCompletion: ((Result<Set<Product>, Error>) -> Void)?
    var getPromotionalOfferCompletion: ((PurchasePluginResult<PromoOffer, Error>) -> Void)?
    var purchaseCompletion: ((PurchasePluginResult<SuccessfulPurchase, Error>) -> Void)?
    var restorePurchasesCompletion: ((Result<PaidFeatures, Error>) -> Void)?
    var appsflyerID: String?
    var attributes: [String : String]?
    var collectDeviceIdentifiersCalled = false
    var codeRedemptionCalled = false
    var codeRedemptionResult: PurchasePluginResult<(), Error>?
    var invalidateCacheCalled = false
    var cancellationToken: CancellationToken?
    var cancellationResult: PurchasePluginResult<(), Error>?
    var restoreEmail: String?
    var restoreResult: PurchasePluginResult<(), Error>?

    func logIn(appUserId: UserId, completion: @escaping (Result<(), Error>) -> Void) {
        logInUserId = appUserId
        logInCompletion = completion
    }

    func logOut() {
        logOutCalled = true
    }
    
    func getPaidFeatures(_ completion: @escaping (Result<PaidFeatures, Error>) -> Void) {
        getPaidFeaturesCompletion = completion
    }
    
    func getProducts(with productIdentifiers: [String], _ completion: @escaping (Result<Set<Product>, Error>) -> Void) {
        getProductsCompletion = completion
        getProductsIndentifiers = productIdentifiers
    }
    
    func getPromotionalOffer(for productDiscount: ProductDiscount, product: Product, _ completion: @escaping (PurchasePluginResult<PromoOffer, Error>) -> Void) {
        getPromotionalOfferCompletion = completion
    }
    
    func purchase(_ product: Product, with promoOffer: PromoOffer?, _ completion: @escaping (PurchasePluginResult<SuccessfulPurchase, Error>) -> Void) {
        purchaseCompletion = completion
    }
    
    func restorePurchases(completion: @escaping (Result<PaidFeatures, Error>) -> Void) {
        restorePurchasesCompletion = completion
    }
    
    func setAppsflyerID(_ appsflyerID: String?) {
        self.appsflyerID = appsflyerID
    }
    
    func setAppsflyerAttributes(_ attributes: [String : String]) {
        self.attributes = attributes
    }
    
    func collectDeviceIdentifiers() {
        collectDeviceIdentifiersCalled = true
    }
    
    func presentCodeRedemptionUI() -> PurchasePluginResult<(), Error> {
        codeRedemptionCalled = true
        return codeRedemptionResult ?? .notSupported
    }
    
    func invalidatePaidFeaturesCache() {
        invalidateCacheCalled = true
    }
    
    func cancelSubscription(with token: PaltaPayments.CancellationToken, completion: @escaping (PurchasePluginResult<Void, Error>) -> Void) {
        cancellationToken = token
        
        if let cancellationResult = cancellationResult {
            completion(cancellationResult)
        }
    }
    
    func sendRestoreLink(to email: String, completion: @escaping (PurchasePluginResult<Void, Error>) -> Void) {
        restoreEmail = email
        
        if let restoreResult = restoreResult {
            completion(restoreResult)
        }
    }
}

extension PurchasePluginMock: Equatable {
    static func ==(lhs: PurchasePluginMock, rhs: PurchasePluginMock) -> Bool {
        lhs === rhs
    }
}
