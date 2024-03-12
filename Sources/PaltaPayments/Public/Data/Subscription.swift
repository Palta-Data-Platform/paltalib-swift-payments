//
//  Subscription.swift
//  
//
//  Created by Vyacheslav Beltyukov on 07/03/2024.
//

import Foundation

public class Subscription {
    public enum State {
        case active
        case expired
        case cancelled
        case upcoming
    }
    
    public enum ChargeType {
        case web
        case apple
        case android
    }
    
    public let productIdentifier: String
    
    public let startDate: Date
    public let endDate: Date
    
    public let state: State
    public let type: ChargeType
    public let price: Decimal
    public let currencyCode: String
    public let period: SubscriptionPeriod
    
    public let providedFeatures: [String]
    
    public let next: Subscription?
    
    init(
        productIdentifier: String,
        startDate: Date,
        endDate: Date,
        state: Subscription.State,
        type: Subscription.ChargeType,
        price: Decimal,
        currencyCode: String,
        period: SubscriptionPeriod,
        providedFeatures: [String],
        next: Subscription?
    ) {
        self.productIdentifier = productIdentifier
        self.startDate = startDate
        self.endDate = endDate
        self.state = state
        self.type = type
        self.price = price
        self.currencyCode = currencyCode
        self.period = period
        self.providedFeatures = providedFeatures
        self.next = next
    }
}