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
    
    public func getProducts(
        with productIdentifiers: [String],
        _ completion: @escaping (Result<Set<Product>, Error>) -> Void
    ) {
        guard let userId = userId else {
            completion(.failure(PaymentsError.noUserId))
            return
        }
        
        assembly.showcaseService.getPricePoints(with: Set(productIdentifiers), for: userId) {
            completion($0
                .mapError { $0 as Error }
                .map {
                    $0.map {
                        Product(
                            productType: $0.payment.productType,
                            productIdentifier: $0.ident,
                            localizedDescription: "",
                            localizedTitle: $0.name,
                            currencyCode: $0.payment.currencyCode,
                            price: $0.payment.price,
                            localizedPriceString: NumberFormatter.formatter(for: $0.payment.currencyCode).string(from: $0.payment.price as NSDecimalNumber) ?? "",
                            formatter: NumberFormatter.formatter(for: $0.payment.currencyCode),
                            subscriptionPeriod: $0.payment.subscriptionPeriod,
                            introductoryDiscount: $0.payment.introductoryDiscount,
                            discounts: [],
                            originalEntity: $0
                        )
                    }
                }
                .map {
                    Set($0)
                }
            )
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
        completion(.notSupported)
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

extension WebPricePoint.PaymentType {
    var productType: ProductType {
        switch self {
        case .intro:
            return .nonRenewableSubscription
        case .subscription:
            return .autoRenewableSubscription
        case .oneTime, .freebie:
            return .nonConsumable
        }
    }
    
    var price: Decimal {
        switch self {
        case .intro(let introPayment):
            return introPayment.price
        case .subscription(let subscriptionPayment):
            return subscriptionPayment.price
        case .oneTime(let oneTimePayment):
            return oneTimePayment.price
        case .freebie:
            return 0
        }
    }
    
    var currencyCode: String {
        switch self {
        case .intro(let introPayment):
            return introPayment.currencyCode
        case .subscription(let subscriptionPayment):
            return subscriptionPayment.currencyCode
        case .oneTime(let oneTimePayment):
            return oneTimePayment.currencyCode
        case .freebie:
            return ""
        }
    }
    
    var subscriptionPeriod: SubscriptionPeriod? {
        switch self {
        case .intro(let introPayment):
            return introPayment.period
        case .subscription(let subscriptionPayment):
            return subscriptionPayment.period
        case .oneTime, .freebie:
            return nil
        }
    }
    
    var introductoryDiscount: ProductDiscount? {
        guard case let .subscription(payment) = self else {
            return nil
        }

        guard payment.period != payment.introPeriod || payment.price != payment.introPrice else {
            return nil
        }
        
        return ProductDiscount(
            offerIdentifier: nil,
            currencyCode: payment.currencyCode,
            price: payment.introPrice,
            numberOfPeriods: 1,
            subscriptionPeriod: payment.introPeriod,
            localizedPriceString: "",
            originalEntity: ""
        )
    }
}

extension NumberFormatter {
    private static var formatters: [String: NumberFormatter] = [:]
    
    static func formatter(for currency: String) -> NumberFormatter {
        if let cached = formatters[currency] {
            return cached
        }
        
        let formatter = NumberFormatter()
        formatter.currencyCode = currency
        formatter.numberStyle = .currency
        formatters[currency] = formatter
        
        return formatter
    }
}
