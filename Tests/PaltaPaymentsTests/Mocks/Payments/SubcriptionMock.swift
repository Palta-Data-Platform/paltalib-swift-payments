//
//  SubcriptionMock.swift
//  
//
//  Created by Vyacheslav Beltyukov on 14/03/2024.
//

import Foundation
@testable import PaltaPayments

extension Subscription {
    static func mock() -> Subscription {
        Subscription(
            id: UUID(),
            productIdentifier: "prodId1",
            startDate: Date(timeIntervalSince1970: 10),
            endDate: Date(timeIntervalSince1970: 20),
            state: .active,
            type: .web,
            price: 8,
            currencyCode: "EUR",
            providedFeatures: [],
            next: nil
        )
    }
}
