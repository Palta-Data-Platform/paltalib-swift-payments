//
//  CustomerInfo+Features.swift
//  
//
//  Created by Vyacheslav Beltyukov on 13/03/2024.
//

import Foundation
import RevenueCat

extension CustomerInfo {
    var features: Features {
        Features(features: entitlements.all.values.map {
            Feature(
                name: $0.identifier,
                startDate: $0.latestPurchaseDate ?? Date(timeIntervalSince1970: 0),
                endDate: $0.expirationDate
            )
        })
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
