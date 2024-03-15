//
//  PBLegacyPurchasePlugin.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 20/01/2023.
//

import Foundation
import PaltaCore

public final class PBLegacyPurchasePlugin: PurchasePlugin {
    public var delegate: PurchasePluginDelegate?
    
    private let webSubscriptionID: String
    private let httpClient: HTTPClient
    
    public init(webSubscriptionID: String) {
        self.webSubscriptionID = webSubscriptionID
        self.httpClient = CoreAssembly().httpClient
    }
    
    public func logIn(appUserId: UserId, completion: @escaping (Result<(), Error>) -> Void) {
    }
    
    public func logOut() {
    }
    
    public func getFeatures(_ completion: @escaping (Result<Features, Error>) -> Void) {
        completion(.success(Features()))
    }
    
    public func getSubscriptions(_ completion: @escaping (Result<[Subscription], Error>) -> Void) {
        completion(.success([]))
    }
    
    @available(*, deprecated, message: "Use getFeatures instead")
    public func getPaidFeatures(_ completion: @escaping (Result<PaidFeatures, Error>) -> Void) {
        completion(.success(PaidFeatures()))
    }
    
    public func getProducts(with productIdentifiers: [String], _ completion: @escaping (Result<Set<Product>, Error>) -> Void) {
        completion(.success([]))
    }
    
    public func getWebPricePoints(
        with ids: Set<String>,
        _ completion: @escaping (Result<[WebPricePoint], Error>) -> Void
    ) {
        completion(.success([]))
    }
    
    public func getPromotionalOffer(for productDiscount: ProductDiscount, product: Product, _ completion: @escaping (PurchasePluginResult<PromoOffer, Error>) -> Void) {
        completion(.notSupported)
    }
    
    @available(*, deprecated, message: "")
    public func purchase(_ product: Product, with promoOffer: PromoOffer?, _ completion: @escaping (PurchasePluginResult<SuccessfulPurchase, Error>) -> Void) {
        completion(.notSupported)
    }
    
    @available(*, deprecated, message: "Use Feature instead")
    public func restorePurchases(completion: @escaping (Result<PaidFeatures, Error>) -> Void) {
        completion(.success(PaidFeatures()))
    }
    
    public func presentCodeRedemptionUI() -> PurchasePluginResult<(), Error> {
        .notSupported
    }
    
    public func setAppsflyerID(_ appsflyerID: String?) {
    }
    
    public func setAppsflyerAttributes(_ attributes: [String : String]) {
    }
    
    public func collectDeviceIdentifiers() {
    }
    
    public func invalidatePaidFeaturesCache() {
    }
    
    public func cancelSubscription(with token: CancellationToken, completion: @escaping (PurchasePluginResult<Void, Error>) -> Void) {
        guard token.pluginId == "web-laegacy" as AnyHashable, let revenueCatID = token.internalId as? String else {
            completion(.notSupported)
            return
        }
        
        let request = PBLegacyHTTPRequest.cancelSubscription(
            PBLegacyCancelRequestData(revenueCatID: revenueCatID, webSubscriptionID: webSubscriptionID)
        )

        httpClient.perform(request) { [unowned self] (result: Result<WebSubscriptionsResponse, NetworkErrorWithResponse<ErrorResponse>>) in
            switch result {
            case let .success(response) where response.message == .redirect:
                guard let url = response.url else {
                    completion(.failure(WebSubscriptionError.networkError(.decodingError(nil))))
                    return
                }
                
                delegate?.purchasePlugin(self, needsToOpenURL: url) { [unowned self] in
                    completeCancel(completion: completion)
                }
            case .success:
                completeCancel(completion: completion)
            case let .failure(error):
                Self.handleError(error, completion: completion)
            }
        }
    }
    
    public func sendRestoreLink(to email: String, completion: @escaping (PurchasePluginResult<Void, Error>) -> Void) {
        let request = PBLegacyHTTPRequest.restoreSubscription(
            PBLegacyRestoreRequestData(email: email, webSubscriptionID: webSubscriptionID)
        )
        
        httpClient.perform(request) { (result: Result<WebSubscriptionsResponse, NetworkErrorWithResponse<ErrorResponse>>) in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                Self.handleError(error, completion: completion)
            }
        }
    }
    
    private static func handleError<T>(
        _ error: NetworkErrorWithResponse<ErrorResponse>,
        completion: @escaping (PurchasePluginResult<T, Error>) -> Void
    ) {
        if case let .invalidStatusCode(_, response) = error {
            completion(.failure(response?.asWebSubscriptionError ?? WebSubscriptionError.networkError(NetworkError(error))))
        } else {
            completion(.failure(WebSubscriptionError.networkError(NetworkError(error))))
        }
    }
    
    private func completeCancel(completion: @escaping (PurchasePluginResult<Void, Error>) -> Void) {
        self.delegate?.purchasePluginRequestsToClearCaches(self)
        completion(.success(()))
    }
}

public enum WebSubscriptionError: Error {
    case noUserFound
    case networkError(NetworkError)
}

private struct WebSubscriptionsResponse: Decodable {
    enum Message: String, Decodable {
        case ok = "OK"
        case redirect = "REDIRECT"
    }
    
    let message: Message
    let url: URL?
}

private struct ErrorResponse: Decodable {
    enum Error: String, Decodable {
        case noUserFound = "Can't find user"
    }

    let error: Error

    var asWebSubscriptionError: WebSubscriptionError? {
        switch error {
        case .noUserFound:
            return .noUserFound
        }
    }
}

