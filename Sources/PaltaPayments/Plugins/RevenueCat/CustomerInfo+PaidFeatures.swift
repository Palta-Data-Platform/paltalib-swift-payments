//
//  CustomerInfo+PaidFeatures.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 13/05/2022.
//

import Foundation
import RevenueCat

extension CustomerInfo {
    private var nonSubscriptionFeatures: [PaidFeature] {
        nonSubscriptions.map {
            PaidFeature(
                name: $0.productIdentifier,
                productIdentifier: $0.productIdentifier,
                pricePointIdent: nil,
                paymentType: .oneOff,
                transactionType: .appStore
            )
        }
    }
    
    func paidFeatures(userId: String) -> PaidFeatures {
        PaidFeatures(
            features: subscriptionFeatures(userId: userId) + nonSubscriptionFeatures
        )
    }
    
    private func subscriptionFeatures(userId: String) -> [PaidFeature] {
        entitlements.all.values.compactMap {
            guard let endDate = $0.expirationDate else {
                return nil
            }
            
            return PaidFeature(
                name: $0.identifier,
                productIdentifier: $0.productIdentifier,
                pricePointIdent: nil,
                paymentType: .subscription(
                    .init(
                        current: .init(
                            id: nil,
                            startDate: $0.latestPurchaseDate ?? Date(timeIntervalSince1970: 0),
                            endDate: endDate,
                            cancellationDate: $0.unsubscribeDetectedAt,
                            cancellationToken: $0.store == .promotional ? CancellationToken(pluginId: "web-laegacy", internalId: userId) : nil,
                            isTrial: $0.periodType == .trial,
                            isIntroductory: $0.periodType == .intro
                        ),
                        next: nil
                    )
                ),
                transactionType: $0.store.transactionType
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
