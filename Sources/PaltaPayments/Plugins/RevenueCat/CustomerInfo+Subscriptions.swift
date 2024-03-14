//
//  CustomerInfo+Subscriptions.swift
//  
//
//  Created by Vyacheslav Beltyukov on 14/03/2024.
//

import Foundation
import RevenueCat

extension CustomerInfo {
    var paltaSubscriptions: [Subscription] {
        entitlements.all.values
            .filter { $0.expirationDate != nil }
            .map {
            Subscription(
                id: nil,
                productIdentifier: $0.productIdentifier,
                startDate: $0.latestPurchaseDate ?? $0.originalPurchaseDate ?? Date(),
                endDate: $0.expirationDate ?? Date(),
                state: $0.state,
                type: $0.subType,
                price: nil,
                currencyCode: nil,
                providedFeatures: [$0.identifier],
                next: nil
            )
        }
    }
}

private extension EntitlementInfo {
    var state: Subscription.State {
        if !isActive {
            return .expired
        } else if willRenew {
            return .active
        } else {
            return .cancelled
        }
    }
    
    var subType: Subscription.ChargeType {
        switch store {
        case .amazon, .playStore:
            return .android
        case .appStore, .macAppStore:
            return .apple
        default:
            assertionFailure()
            return .web
        }
    }
}
