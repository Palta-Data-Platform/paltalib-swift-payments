//
//  CustomerInfo+Features.swift
//  
//
//  Created by Vyacheslav Beltyukov on 13/03/2024.
//

import Foundation
import RevenueCat

extension CustomerInfo {
    private var nonSubscriptionFeatures: [Feature] {
        nonSubscriptions.map {
            Feature(
                name: $0.productIdentifier,
                startDate: $0.purchaseDate,
                endDate: nil
            )
        }
    }
    
    private var subscriptionFeatures: [Feature] {
        entitlements.all.values.map {
            Feature(
                name: $0.identifier,
                startDate: $0.latestPurchaseDate ?? Date(timeIntervalSince1970: 0),
                endDate: $0.expirationDate
            )
        }
    }
    
    var features: Features {
        Features(
            features: subscriptionFeatures + nonSubscriptionFeatures
        )
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
