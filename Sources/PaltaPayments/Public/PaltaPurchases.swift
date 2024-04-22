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
        checkSetupFinished()
        
        callAndCollect(
            call: { $0.getSubscriptions($1) },
            completion: {
                switch $0 {
                case let .success(subs):
                    completion(.success(subs.flatMap { $0 }))
                    
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        )
    }
    
    
    @available(*, deprecated, message: "Method was renamed to `getProductsAndPricePoints`")
    public func getProducts(
        with productIdentifiers: [String],
        completion: @escaping (Result<Set<Product>, Error>) -> Void
    ) {
        getProductsAndPricePoints(with: productIdentifiers, completion: completion)
    }
    
    public func getProductsAndPricePoints(
        with identifiers: [String],
        completion: @escaping (Result<Set<Product>, Error>) -> Void
    ) {
        callAndCollect(call: { plugIn, callback in
            plugIn.getProductsAndPricePoints(with: identifiers, callback)
        }, completion: { result in
            completion(
                result.map { $0.reduce([]) { $0.union($1) } }
            )
        })
    }
    
    public func getWebPricePoints(
        with ids: Set<String>,
        _ completion: @escaping (Result<[WebPricePoint], Error>) -> Void
    ) {
        checkSetupFinished()
        
        callAndCollect(call: { plugin, callback in
            plugin.getWebPricePoints(with: ids, callback)
        }, completion: { result in
            completion(result.map { $0.flatMap { $0 } })
        })
    }
    
    @available(iOS 12.2, *)
    public func getPromotionalOffer(
        for productDiscount: ProductDiscount,
        product: Product,
        _ completion: @escaping (Result<PromoOffer, Error>) -> Void
    ) {
        checkSetupFinished()

        start(completion: { result, _ in completion(result) }) { plugin, completion in
            plugin.getPromotionalOffer(for: productDiscount, product: product, completion)
        }
    }

    public func purchase(
        _ product: Product,
        with promoOffer: PromoOffer?,
        _ completion: @escaping (Result<SuccessfulPurchase, Error>) -> Void
    ) {
        checkSetupFinished()

        typealias Res = Result<SuccessfulPurchase, Error>
        let purchaseCompletion = { [self] (result: Res, usedPlugin: PurchasePlugin?) in
            switch result {
            case let .success(purchase):
                postPurchase(purchase, usedPlugin: usedPlugin, completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }

        start(completion: purchaseCompletion) { plugin, completion in
            plugin.purchase(product, with: promoOffer, completion)
        }
    }
    
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
        start(completion: { result, _ in completion(result) }) { plugin, completion in
            plugin.cancelSubscription(with: token, completion: completion)
        }
    }
    
    public func sendRestoreLink(to email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        start(completion: { result, _ in completion(result) })  { plugin, completion in
            plugin.sendRestoreLink(to: email, completion: completion)
        }
    }
    
    private func start<T>(
        completion: @escaping (Result<T, Error>, PurchasePlugin?) -> Void,
        execute: @escaping (PurchasePlugin, @escaping (PurchasePluginResult<T, Error>) -> Void) -> Void
    ) {
        guard let firstPlugin = plugins.first else {
            return
        }
        
        with(firstPlugin, completion: completion, execute: execute)
    }
    
    private func with<T>(
        _ plugin: PurchasePlugin,
        completion: @escaping (Result<T, Error>, PurchasePlugin?) -> Void,
        execute: @escaping (PurchasePlugin, @escaping (PurchasePluginResult<T, Error>) -> Void) -> Void
    ) {
        execute(plugin) { [weak self, unowned plugin] pluginResult in
            guard let self = self else {
                return
            }
            
            if let result = pluginResult.result {
                DispatchQueue.main.async {
                    completion(result, plugin)
                }
            } else if let nextPlugin = self.plugins.nextElement(after: { $0 === plugin }) {
                self.with(nextPlugin, completion: completion, execute: execute)
            } else {
                completion(.failure(PaymentsError.sdkError(.noSuitablePlugin)), nil)
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
        excluding excludedPlugins: [PurchasePlugin] = [],
        completion: @escaping (Result<[T], Error>) -> Void
    ) {
        var values: [T] = []
        var error: Error?
        
        let lock = NSRecursiveLock()
        let group = DispatchGroup()
        
        plugins
            .filter { plugin in
                !excludedPlugins.contains(where: { $0 === plugin })
            }
            .forEach { plugin in
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
    
    private func callAndCollectPaidFeatures(
        to completion: @escaping (Result<PaidFeatures, Error>) -> Void,
        excluding excludedPlugins: [PurchasePlugin] = [],
        call: (PurchasePlugin, @escaping (Result<PaidFeatures, Error>) -> Void) -> Void
    ) {
        callAndCollect(call: call, excluding: excludedPlugins) { result in
            completion(
                result.map {
                    $0.reduce(PaidFeatures()) {
                        $0.merged(with: $1)
                    }
                }
            )
        }
    }

    /// Here we combine recently purchased features with the ones purchased before in other plugins
    private func postPurchase(
        _ purchase: SuccessfulPurchase,
        usedPlugin: PurchasePlugin?,
        _ completion: @escaping (Result<SuccessfulPurchase, Error>) -> Void
    ) {
        callAndCollectPaidFeatures(
            to: { result in
                switch result {
                case .success(let paidFeatures):
                    completion(
                        .success(
                            SuccessfulPurchase(
                                transaction: purchase.transaction,
                                paidFeatures: purchase.paidFeatures.merged(with: paidFeatures)
                            )
                        )
                    )
                case .failure:
                    // Anyway, purchase itself was successful
                    completion(.success(purchase))
                }
            },
            excluding: [usedPlugin].compactMap { $0 },
            call: { plugin, completion in
                plugin.getPaidFeatures(completion)
            }
        )
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
