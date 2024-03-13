//
//  PaltaPurchases.swift
//  PaltaCore
//
//  Created by Vyacheslav Beltyukov on 04.05.2022.
//

import Foundation
import PaltaCore

public final class PaltaPurchases: PaltaPurchasesProtocol {
    public static let instance = PaltaPurchases()
    
    public private(set) var userId: UserId?
    
    public weak var delegate: PaltaPurchasesDelegate?

    var setupFinished = false
    var plugins: [PurchasePlugin] = [] {
        didSet {
            plugins.forEach {
                $0.delegate = self
            }
        }
    }
    
    public func setup(with plugins: [PurchasePlugin]) {
        setup(with: plugins, appUserId: nil)
    }

    public func setup(with plugins: [PurchasePlugin], appUserId: UserId?) {
        guard !setupFinished else {
            assertionFailure("Attempt to setup PaltaPurchases twice")
            return
        }

        setupFinished = true
        self.plugins = plugins
        
        if let appUserId = appUserId {
            self.logIn(appUserId: appUserId, completion: { _ in })
        }
    }
    
    public func logIn(appUserId: UserId, completion: @escaping (Result<(), Error>) -> Void) {
        checkSetupFinished()
        
        callAndCollect(call: { plugin, callback in
            plugin.logIn(appUserId: appUserId, completion: callback)
        }, completion: { [weak self] result in
            switch result {
            case .success:
                self?.userId = appUserId
                
            case .failure:
                // Some plugins definetly failed, but some may be logged in. Need to logout.
                self?.logOut()
            }
            
            completion(result.map { _ in })
        })
    }
    
    public func logOut() {
        checkSetupFinished()
        
        userId = nil
        plugins.forEach {
            $0.logOut()
        }
    }
    
    @available(*, deprecated, message: "Use getFeatures and/or getSubscriptions instead")
    public func getPaidFeatures(_ completion: @escaping (Result<PaidFeatures, Error>) -> Void) {
        checkSetupFinished()
        
        callAndCollectPaidFeatures(to: completion) { plugin, callback in
            plugin.getPaidFeatures(callback)
        }
    }
    
    public func getFeatures(_ completion: @escaping (Result<Features, Error>) -> Void) {
        checkSetupFinished()
        
        callAndCollectFeatures(to: completion) { plugin, callback in
            plugin.getFeatures(callback)
        }
    }
    
    public func getSubscriptions(_ completion: @escaping (Result<[Subscription], Error>) -> Void) {
        fatalError()
    }
    
//    public func getPricePoints(with ids: [String], _ completion: @escaping (Result<[PricePoint], Error>) -> Void) {
//        fatalError()
//    }
    
    public func getProducts(
        with productIdentifiers: [String],
        completion: @escaping (Result<Set<Product>, Error>) -> Void
    ) {
        callAndCollect(call: { plugIn, callback in
            plugIn.getProducts(with: productIdentifiers, callback)
        }, completion: { result in
            completion(
                result.map { $0.reduce([]) { $0.union($1) } }
            )
        })
    }
    
    @available(iOS 12.2, *)
    public func getPromotionalOffer(
        for productDiscount: ProductDiscount,
        product: Product,
        _ completion: @escaping (Result<PromoOffer, Error>) -> Void
    ) {
        checkSetupFinished()
    
        start(completion: completion) { plugin, completion in
            plugin.getPromotionalOffer(for: productDiscount, product: product, completion)
        }
    }
    
    @available(*, deprecated, message: "Use purchase2 method instead")
    public func purchase(
        _ product: Product,
        with promoOffer: PromoOffer?,
        _ completion: @escaping (Result<SuccessfulPurchase, Error>) -> Void
    ) {
        checkSetupFinished()
        
        start(completion: completion) { plugin, completion in
            plugin.purchase(product, with: promoOffer, completion)
        }
    }
    
    public func purchase2(
        _ product: Product,
        with promoOffer: PromoOffer?,
        _ completion: @escaping (Result<SuccessfulPurchase2, Error>) -> Void
    ) {
        fatalError()
    }
    
    @available(*, deprecated, message: "Use restorePurchases with Features callback instead")
    public func restorePurchases(completion: @escaping (Result<PaidFeatures, Error>) -> Void) {
        checkSetupFinished()
        
        callAndCollectPaidFeatures(to: completion) { plugin, callback in
            plugin.restorePurchases(completion: callback)
        }
    }
    
    public func restorePurchases(completion: @escaping (Result<Features, Error>) -> Void) {
        fatalError()
    }
    
    public func setAppsflyerID(_ appsflyerID: String?) {
        checkSetupFinished()
        
        plugins.forEach {
            $0.setAppsflyerID(appsflyerID)
        }
    }
    
    public func setAppsflyerAttributes(_ attributes: [String: String]) {
        checkSetupFinished()
        
        plugins.forEach {
            $0.setAppsflyerAttributes(attributes)
        }
    }
    
    public func collectDeviceIdentifiers() {
        checkSetupFinished()
        
        plugins.forEach {
            $0.collectDeviceIdentifiers()
        }
    }
    
    @available(iOS 14.0, *)
    public func presentCodeRedemptionUI() {
        var iterator = plugins.makeIterator()
        
        while let plugin = iterator.next() {
            if case .success = plugin.presentCodeRedemptionUI() {
                return
            }
        }
        
        print("PaltaLib: Purchases: Error: No plugin could present code redemption UI")
    }
    
    public func invalidatePaidFeaturesCache() {
        plugins.forEach {
            $0.invalidatePaidFeaturesCache()
        }
    }
    
    public func cancelSubscription(with token: CancellationToken, completion: @escaping (Result<Void, Error>) -> Void) {
        start(completion: completion) { plugin, completion in
            plugin.cancelSubscription(with: token, completion: completion)
        }
    }
    
    public func sendRestoreLink(to email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        start(completion: completion)  { plugin, completion in
            plugin.sendRestoreLink(to: email, completion: completion)
        }
    }
    
    private func start<T>(
        completion: @escaping (Result<T, Error>) -> Void,
        execute: @escaping (PurchasePlugin, @escaping (PurchasePluginResult<T, Error>) -> Void) -> Void
    ) {
        guard let firstPlugin = plugins.first else {
            return
        }
        
        with(firstPlugin, completion: completion, execute: execute)
    }
    
    private func with<T>(
        _ plugin: PurchasePlugin,
        completion: @escaping (Result<T, Error>) -> Void,
        execute: @escaping (PurchasePlugin, @escaping (PurchasePluginResult<T, Error>) -> Void) -> Void
    ) {
        execute(plugin) { [weak self, unowned plugin] pluginResult in
            guard let self = self else {
                return
            }
            
            if let result = pluginResult.result {
                DispatchQueue.main.async {
                    completion(result)
                }
            } else if let nextPlugin = self.plugins.nextElement(after: { $0 === plugin }) {
                self.with(nextPlugin, completion: completion, execute: execute)
            } else {
                completion(.failure(PaymentsError.sdkError(.noSuitablePlugin)))
            }
        }
    }

    private func checkSetupFinished() {
        if !setupFinished {
            assertionFailure("Setup palta purchases with plugins first!")
        }
    }
    
    private func callAndCollect<T>(
        call: (PurchasePlugin, @escaping (Result<T, Error>) -> Void) -> Void,
        completion: @escaping (Result<[T], Error>) -> Void
    ) {
        var values: [T] = []
        var error: Error?
        
        let lock = NSRecursiveLock()
        let group = DispatchGroup()
        
        plugins.forEach { plugin in
            group.enter()
            call(plugin) { result in
                lock.lock()
                
                switch result {
                case .success(let value):
                    values.append(value)
                    
                case .failure(let err):
                    error = error ?? err
                }
                
                lock.unlock()
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(values))
            }
        }
    }
    
    private func callAndCollectFeatures(
        to completion: @escaping (Result<Features, Error>) -> Void,
        call: (PurchasePlugin, @escaping (Result<Features, Error>) -> Void) -> Void
    ) {
        callAndCollect(call: call) { result in
            completion(
                result.map {
                    $0.reduce(Features()) {
                        $0.merged(with: $1)
                    }
                }
            )
        }
    }
    
    @available(*, deprecated, message: "Use `callAndCollectFeatures` instead")
    private func callAndCollectPaidFeatures(
        to completion: @escaping (Result<PaidFeatures, Error>) -> Void,
        call: (PurchasePlugin, @escaping (Result<PaidFeatures, Error>) -> Void) -> Void
    ) {
        callAndCollect(call: call) { result in
            completion(
                result.map {
                    $0.reduce(PaidFeatures()) {
                        $0.merged(with: $1)
                    }
                }
            )
        }
    }
}

extension PaltaPurchases: PurchasePluginDelegate {
    public func purchasePlugin(
        _ plugin: PurchasePlugin,
        shouldPurchase promoProduct: Product,
        defermentCallback: @escaping DefermentCallback
    ) {
        delegate?.purchases(self, shouldPurchase: promoProduct, defermentCallback: { completion in
            defermentCallback {
                switch $0 {
                case .success(let purchase):
                    completion(.success(purchase))
                    
                case .failure(let error):
                    completion(.failure(error))
                    
                case .notSupported:
                    completion(.failure(PaymentsError.sdkError(.other(nil))))
                }
            }
        })
    }
    
    public func purchasePlugin(_ plugin: PurchasePlugin, needsToOpenURL url: URL, completion: @escaping () -> Void) {
        delegate?.paltaPurchases(self, needsToOpenURL: url, completion: completion)
    }
    
    public func purchasePluginRequestsToClearCaches(_ plugin: PurchasePlugin) {
        invalidatePaidFeaturesCache()
    }
}
