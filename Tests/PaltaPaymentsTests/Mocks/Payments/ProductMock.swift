//
//  ProductMock.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 12/05/2022.
//

import Foundation
@testable import PaltaPayments

extension Product {
    static func mock(productIdentifier: String = "") -> Product {
        .init(
            productType: .nonRenewableSubscription,
            productIdentifier: productIdentifier,
            localizedDescription: "",
            localizedTitle: "",
            currencyCode: nil,
            price: 0,
            localizedPriceString: "",
            originalEntity: 0
        )
    }
}
