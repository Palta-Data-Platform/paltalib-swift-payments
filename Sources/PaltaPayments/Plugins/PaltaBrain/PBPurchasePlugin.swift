//
//  PBPurchasePlugin.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 04.05.2022.
//

import Foundation

public final class PBPurchasePlugin: PurchasePlugin {
    public var delegate: PurchasePluginDelegate?
    
    var userId: UserId?

    private let assembly: PaymentsAssembly

    init(assembly: PaymentsAssembly) {
        self.assembly = assembly
    }
    
    public func logIn(appUserId: UserId, completion: @escaping (Result<(), Error>) -> Void) {
        userId = appUserId
        completion(.success(()))
    }
    
    public func logOut() {
        userId = nil
    }
    
    public func getFeatures(_ completion: @escaping (Result<Features, Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(PaymentsError.noUserId))
            return
        }

        assembly.newFeaturesService.getFeatures(for: userId) {
            completion($0.mapError { $0 as Error })
        }
    }
    
    public func getSubscriptions(_ completion: @escaping (Result<[Subscription], Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(PaymentsError.noUserId))
            return
        }
        
        assembly.publicSubscriptionsService.getSubscriptions(for: userId) {
            completion($0.mapError { $0 as Error })
        }
    }
    
    public func getPaidFeatures(_ completion: @escaping (Result<PaidFeatures, Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(PaymentsError.noUserId))
            return
        }

        assembly.paidFeaturesService.getPaidFeatures(for: userId) {
            completion($0.mapError { $0 as Error })
        }
    }
    
    public func getProductsAndPricePoints(
        with identifiers: [String],
        _ completion: @escaping (Result<Set<Product>, Error>) -> Void
    ) {
        guard let userId = userId else {
            completion(.failure(PaymentsError.noUserId))
            return
        }
        
        assembly.showcaseService.getProducts(with: identifiers, for: userId) { result in
            completion(result.mapError { $0 as Error })
        }
    }
    
    public func getWebPricePoints(
        with ids: Set<String>,
        _ completion: @escaping (Result<[WebPricePoint], Error>) -> Void
    ) {
        guard let userId = userId else {
            completion(.failure(PaymentsError.noUserId))
            return
        }
        
        assembly.showcaseService.getPricePoints(with: ids, for: userId) {
            completion($0.mapError { $0 as Error })
        }
    }
    
    public func getPromotionalOffer(
        for productDiscount: ProductDiscount,
        product: Product,
        _ completion: @escaping (PurchasePluginResult<PromoOffer, Error>) -> Void
    ) {
        completion(.notSupported)
    }
    
    public func purchase(
        _ product: Product,
        with promoOffer: PromoOffer?,
        _ completion: @escaping (PurchasePluginResult<SuccessfulPurchase, Error>) -> Void
    ) {
        if product.originalEntity is WebPricePoint {
            completion(.failure(PaymentsError.webPaymentsNotSupported))
        } else {
            completion(.notSupported)
        }
    }
    
    public func restorePurchases(completion: @escaping (Result<PaidFeatures, Error>) -> Void) {
        getPaidFeatures(completion)
    }
    
    public func presentCodeRedemptionUI() -> PurchasePluginResult<(), Error> {
        return .notSupported
    }
    
    public func setAppsflyerID(_ appsflyerID: String?) {
    }
    
    public func setAppsflyerAttributes(_ attributes: [String : String]) {
    }
    
    public func collectDeviceIdentifiers() {
    }
    
    public func invalidatePaidFeaturesCache() {
    }
    
    public func sendRestoreLink(to email: String, completion: @escaping (PurchasePluginResult<Void, Error>) -> Void) {
        completion(.notSupported)
    }
    
    public func cancelSubscription(with token: CancellationToken, completion: @escaping (PurchasePluginResult<Void, Error>) -> Void) {
        completion(.notSupported)
    }
}

public extension PBPurchasePlugin {
    convenience init(apiKey: String, environment: Environment) {
        self.init(assembly: RealPaymentsAssembly(apiKey: apiKey, environment: environment))
    }
}
