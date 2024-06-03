//
//  PaidFeature.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import Foundation

public struct PaidFeature: Hashable {
    public enum PaymentType: Hashable {
        case subscription(Subscriptions)
        case oneOff
        case consumable
    }
    
    public enum TransactionType: Hashable {
        case web
        case appStore
        case googlePlay
    }
    
    public struct Subscription: Hashable {
        /// Subscription id is available for Palta MPP subscriptions only
        public let id: UUID?
        public let startDate: Date
        public let endDate: Date
        public let cancellationDate: Date?
        
        public let cancellationToken: CancellationToken?
        
        public let isTrial: Bool
        public let isIntroductory: Bool

        /// Price information is available for Palta MPP subscriptions only
        public let price: Decimal?
        /// Price information is available for Palta MPP subscriptions only
        public let currencyCode: String?
        /// Subscription period information is available for Palta MPP subscriptions only
        public let subscriptionPeriod: SubscriptionPeriod?
    }
    
    public struct Subscriptions: Hashable {
        public let current: Subscription
        public let next: Subscription?
    }
    
    public let name: String
    public let productIdentifier: String?
    public let pricePointIdent: String?
    public let paymentType: PaymentType
    public let transactionType: TransactionType
}

extension PaidFeature {
    public var isLifetime: Bool {
        paymentType == .oneOff
    }
    
    public var isActive: Bool {
        guard case let .subscription(subscriptions) = paymentType else {
            return true
        }
        
        let now = Date()
        
        return now > subscriptions.current.startDate
        && subscriptions.current.endDate > now
    }
}
