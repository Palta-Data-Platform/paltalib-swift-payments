//
//  FeatureMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
@testable import PaltaPayments

extension FeatureInternal {
    static func mock(lastSubscriptionId: UUID? = nil) -> FeatureInternal {
        FeatureInternal(
            quantity: 1,
            actualFrom: Date(timeIntervalSince1970: 0),
            actualTill: Date(timeIntervalSince1970: 100),
            feature: "sku-mock",
            lastSubscriptionId: lastSubscriptionId
        )
    }
}
