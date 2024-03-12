//
//  CustomerInfo+PaidFeatures.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 13/05/2022.
//

import Foundation
import RevenueCat

@available(*, deprecated, message: "Use Feature instead")
extension CustomerInfo {
    private var nonSubscriptionFeatures: [PaidFeature] {
        nonSubscriptions.map {
            PaidFeature(
                name: $0.productIdentifier,
                productIdentifier: $0.productIdentifier,
                paymentType: .oneOff,
                transactionType: .appStore,
                isTrial: false,
                isIntroductory: false,
                willRenew: false,
                startDate: $0.purchaseDate,
                endDate: nil,
                cancellationDate: nil,
                cancellationToken: nil
            )
        }
    }
    
    func paidFeatures(userId: String) -> PaidFeatures {
        PaidFeatures(
            features: subscriptionFeatures(userId: userId) + nonSubscriptionFeatures
        )
    }
    
    private func subscriptionFeatures(userId: String) -> [PaidFeature] {
        entitlements.all.values.map {
            PaidFeature(
                name: $0.identifier,
                productIdentifier: $0.productIdentifier,
                paymentType: .subscription,
                transactionType: $0.store.transactionType,
                isTrial: $0.periodType == .trial,
                isIntroductory: $0.periodType == .intro,
                willRenew: $0.willRenew,
                startDate: $0.latestPurchaseDate ?? Date(timeIntervalSince1970: 0),
                endDate: $0.expirationDate,
                cancellationDate: $0.unsubscribeDetectedAt,
                cancellationToken: $0.store == .promotional ? CancellationToken(pluginId: "web-laegacy", internalId: userId) : nil
            )
        }
    }
}

@available(*, deprecated, message: "Use Feature instead")
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
