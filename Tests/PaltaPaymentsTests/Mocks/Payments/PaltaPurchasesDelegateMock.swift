//
//  PaltaPurchasesDelegateMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 08/06/2022.
//

import Foundation
import PaltaPayments

final class PaltaPurchasesDelegateMock: PaltaPurchasesDelegate {
    var product: Product?
    var callback: DefermentCallback?
    
    var url: URL?
    var urlCallback: (() -> Void)?
    
    func purchases(
        _ purchases: PaltaPurchases,
        shouldPurchase promoProduct: Product,
        defermentCallback: @escaping DefermentCallback
    ) {
        self.product = promoProduct
        self.callback = defermentCallback
    }
    
    func paltaPurchases(
        _ purchases: PaltaPurchases,
        needsToOpenURL url: URL,
        completion: @escaping () -> Void
    ) {
        self.url = url
        self.urlCallback = completion
    }
}
