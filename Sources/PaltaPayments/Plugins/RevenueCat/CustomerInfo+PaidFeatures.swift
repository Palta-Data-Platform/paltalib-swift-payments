//
//  CustomerInfo+PaidFeatures.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 13/05/2022.
//

import Foundation
import RevenueCat

extension CustomerInfo {
    func paidFeatures(userId: String) -> PaidFeatures {
        PaidFeatures(
            features: paidFeatures(userId: userId)
        )
    }
    
    private func paidFeatures(userId: String) -> [PaidFeature] {
        entitlements.all.values.compactMap { entitlement in
            let paymentType: PaidFeature.PaymentType

            if nonSubscriptions.contains(where: { $0.productIdentifier == entitlement.productIdentifier }) {
                paymentType = .oneOff
            } else if let endDate = entitlement.expirationDate {
                paymentType = .subscription(
                    .init(
                        current: .init(
                            id: nil,
                            startDate: entitlement.latestPurchaseDate ?? Date(timeIntervalSince1970: 0),
                            endDate: endDate,
                            cancellationDate: entitlement.unsubscribeDetectedAt,
                            cancellationToken: entitlement.store == .promotional ? CancellationToken(pluginId: "web-laegacy", internalId: userId) : nil,
                            isTrial: entitlement.periodType == .trial,
                            isIntroductory: entitlement.periodType == .intro,
                            price: nil,
                            currencyCode: nil,
                            subscriptionPeriod: nil,
                            introPrice: nil,
                            introSubscriptionPeriod: nil
                        ),
                        next: nil
                    )
                )
            } else {
                return nil
            }

            return PaidFeature(
                name: entitlement.identifier,
                productIdentifier: entitlement.productIdentifier,
                pricePointIdent: nil,
                paymentType: paymentType,
                transactionType: entitlement.store.transactionType
            )
        }
    }
}

private extension Store {
    var transactionType: PaidFeature.TransactionType {
        switch self {
        case .appStore, .macAppStore:
            return .appStore
        case .playStore, .amazon:
            return .googlePlay
        case .stripe, .promotional, .unknownStore:
            return .web
        }
    }
}
