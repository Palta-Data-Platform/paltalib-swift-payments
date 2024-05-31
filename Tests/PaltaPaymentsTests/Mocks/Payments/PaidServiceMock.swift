//
//  PaidFeatureMock.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 17/05/2022.
//

@testable import PaltaPayments
import Foundation

extension PaidFeature {
    init(name: String, startDate: Date, endDate: Date? = nil) {
        self.init(
            name: name,
            productIdentifier: nil,
            pricePointIdent: nil,
            paymentType: endDate.flatMap { endDate in
                    .subscription(
                        .init(
                            current: Subscription(
                                id: UUID(), 
                                startDate: startDate,
                                endDate: endDate,
                                cancellationDate: nil,
                                cancellationToken: nil,
                                isTrial: false,
                                isIntroductory: false),
                            next: nil
                        )
                    )
            } ?? .oneOff,
            transactionType: .appStore
        )
    }
}
