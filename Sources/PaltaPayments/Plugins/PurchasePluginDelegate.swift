//
//  PurchasePluginDelegate.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import Foundation

public protocol PurchasePluginDelegate {
    typealias DefermentCallback = (@escaping (PurchasePluginResult<SuccessfulPurchase, Error>) -> Void) -> Void
    
    func purchasePlugin(
        _ plugin: PurchasePlugin,
        shouldPurchase promoProduct: Product,
        defermentCallback: @escaping DefermentCallback
    )
    
    func purchasePlugin(
        _ plugin: PurchasePlugin,
        needsToOpenURL: URL,
        completion: @escaping () -> Void
    )
    
    func purchasePluginRequestsToClearCaches(
        _ plugin: PurchasePlugin
    )
}
