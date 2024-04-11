//
//  PaltaPurchasesProtocol.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 11/07/2022.
//

import Foundation

public protocol PaltaPurchasesProtocol: AnyObject {
    var userId: UserId? { get }
    
    var delegate: PaltaPurchasesDelegate? { get set }

    func setup(with plugins: [PurchasePlugin])
    
    func setup(with plugins: [PurchasePlugin], appUserId: UserId?)
    
    func logIn(appUserId: UserId, completion: @escaping (Result<(), Error>) -> Void)
    
    func logOut()
    
    func getPaidFeatures(_ completion: @escaping (Result<PaidFeatures, Error>) -> Void)
    
    func getFeatures(_ completion: @escaping (Result<Features, Error>) -> Void)
    
    func getSubscriptions(_ completion: @escaping (Result<[Subscription], Error>) -> Void)
    
    @available(*, deprecated, message: "Method was renamed to `getProductsAndPricePoints`")
    func getProducts(
        with productIdentifiers: [String],
        completion: @escaping (Result<Set<Product>, Error>) -> Void
    )
    
    func getProductsAndPricePoints(
        with productIdentifiers: [String],
        completion: @escaping (Result<Set<Product>, Error>) -> Void
    )
    
    func getWebPricePoints(
        with ids: Set<String>,
        _ completion: @escaping (Result<[WebPricePoint], Error>) -> Void
    )
    
    @available(iOS 12.2, *)
    func getPromotionalOffer(
        for productDiscount: ProductDiscount,
        product: Product,
        _ completion: @escaping (Result<PromoOffer, Error>) -> Void
    )
    
    func purchase(
        _ product: Product,
        with promoOffer: PromoOffer?,
        _ completion: @escaping (Result<SuccessfulPurchase, Error>) -> Void
    )
    
    func purchase2(
        _ product: Product,
        with promoOffer: PromoOffer?,
        _ completion: @escaping (Result<SuccessfulPurchase2, Error>) -> Void
    )
    
    func restorePurchases(completion: @escaping (Result<PaidFeatures, Error>) -> Void)
    
    func restorePurchases(completion: @escaping (Result<Features, Error>) -> Void)
    
    @available(iOS 14.0, *)
    func presentCodeRedemptionUI()
    
    func setAppsflyerID(_ appsflyerID: String?)
    
    func setAppsflyerAttributes(_ attributes: [String: String])
    
    func collectDeviceIdentifiers()
    
    func invalidatePaidFeaturesCache()
    
    func cancelSubscription(with token: CancellationToken, completion: @escaping (Result<Void, Error>) -> Void)
    
    func sendRestoreLink(to email: String, completion: @escaping (Result<Void, Error>) -> Void)
}
