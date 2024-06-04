//
//  SubscriptionMock.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
@testable import PaltaPayments

extension SubscriptionInternal {
    static func mock(
        ident: String = "ident1",
        id: UUID = UUID(),
        nextId: UUID? = nil
    ) -> SubscriptionInternal {
        SubscriptionInternal(
            id: id,
            state: .active,
            createdAt: Date(timeIntervalSince1970: 0),
            canceledAt: Date(timeIntervalSince1970: 12),
            currentPeriodStartAt: Date(timeIntervalSince1970: 6),
            currentPeriodEndAt: Date(timeIntervalSince1970: 18),
            nextSubscriptionId: nextId,
            pricePoint: PricePoint(
                ident: ident,
                services: [.init(featureIdent: "feature1")],
                currencyCode: "USD",
                nextTotalPrice: "990.98",
                nextPeriodValue: nil,
                nextPeriodType: nil,
                introTotalPrice: "",
                introPeriodValue: nil,
                introPeriodType: nil
            ),
            tags: [.trial]
        )
    }
}
