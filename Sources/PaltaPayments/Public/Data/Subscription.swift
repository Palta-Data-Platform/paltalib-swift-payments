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
        case other
    }
    
    public let id: UUID?
    
    public let productIdentifier: String
    
    public let startDate: Date
    public let endDate: Date
    
    public let state: State
    public let type: ChargeType
    public let price: Decimal?
    public let currencyCode: String?
    
    public let providedFeatures: [String]
    
    public internal(set) var next: Subscription?
    
    init(
        id: UUID?,
        productIdentifier: String,
        startDate: Date,
        endDate: Date,
        state: Subscription.State,
        type: Subscription.ChargeType,
        price: Decimal?,
        currencyCode: String?,
        providedFeatures: [String],
        next: Subscription?
    ) {
        self.id = id
        self.productIdentifier = productIdentifier
        self.startDate = startDate
        self.endDate = endDate
        self.state = state
        self.type = type
        self.price = price
        self.currencyCode = currencyCode
        self.providedFeatures = providedFeatures
        self.next = next
    }
}
