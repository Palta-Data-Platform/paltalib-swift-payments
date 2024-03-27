//
//  PurchasePlugin.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 04.05.2022.
//

import Foundation

public protocol PurchasePlugin: AnyObject {
    var delegate: PurchasePluginDelegate? { get set }

    func logIn(appUserId: UserId, completion: @escaping (Result<(), Error>) -> Void)
    func logOut()
    
    func getFeatures(_ completion: @escaping (Result<Features, Error>) -> Void)
    
    func getSubscriptions(_ completion: @escaping (Result<[Subscription], Error>) -> Void)
    
    func getPaidFeatures(_ completion: @escaping (Result<PaidFeatures, Error>) -> Void)
    
    func getProducts(
        with productIdentifiers: [String],
        _ completion: @escaping (Result<Set<Product>, Error>) -> Void
    )
    
    func getWebPricePoints(
        with ids: Set<String>,
        _ completion: @escaping (Result<[WebPricePoint], Error>) -> Void
    )
    
    @available(iOS 12.2, *)
    func getPromotionalOffer(
        for productDiscount: ProductDiscount,
        product: Product,
        _ completion: @escaping (PurchasePluginResult<PromoOffer, Error>) -> Void
    )
    
    func purchase(
        _ product: Product,
        with promoOffer: PromoOffer?,
        _ completion: @escaping (PurchasePluginResult<SuccessfulPurchase, Error>) -> Void
    )

    func restorePurchases(completion: @escaping (Result<PaidFeatures, Error>) -> Void)
    
    @available(iOS 14.0, *)
    func presentCodeRedemptionUI() -> PurchasePluginResult<(), Error>
    
    func setAppsflyerID(_ appsflyerID: String?)
    func setAppsflyerAttributes(_ attributes: [String: String])
    func collectDeviceIdentifiers()
    
    func invalidatePaidFeaturesCache()
    func cancelSubscription(with token: CancellationToken, completion: @escaping (PurchasePluginResult<Void, Error>) -> Void)
    func sendRestoreLink(to email: String, completion: @escaping (PurchasePluginResult<Void, Error>) -> Void)
}
