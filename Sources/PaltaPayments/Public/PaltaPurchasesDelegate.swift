//
//  PaltaPurchasesDelegate.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 08/06/2022.
//

import Foundation

public protocol PaltaPurchasesDelegate: AnyObject {
    @available(*, deprecated, message: "")
    typealias DefermentCallback = (@escaping (Result<SuccessfulPurchase, Error>) -> Void) -> Void
    
    typealias DefermentCallback2 = (@escaping (Result<SuccessfulPurchase2, Error>) -> Void) -> Void
    
    @available(*, deprecated, message: "")
    func purchases(
        _ purchases: PaltaPurchases,
        shouldPurchase promoProduct: Product,
        defermentCallback: @escaping DefermentCallback
    )
    
    func purchases(
        _ purchases: PaltaPurchases,
        shouldPurchase promoProduct: Product,
        defermentCallback: @escaping DefermentCallback2
    )
    
    func paltaPurchases(
        _ purchases: PaltaPurchases,
        needsToOpenURL: URL,
        completion: @escaping () -> Void
    )
}
