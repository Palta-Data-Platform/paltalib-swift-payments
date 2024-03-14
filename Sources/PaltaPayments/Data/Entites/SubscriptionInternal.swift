//
//  SubscriptionInternal.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation

struct SubscriptionInternal: Decodable, Equatable {
    enum State: String, Decodable, Equatable {
        case new
        case active
        case cancelled = "canceled"
        case upcoming = "is_upcoming"
    }
    
    struct Tag: RawRepresentable, Decodable, Equatable {
        typealias RawValue = String
        
        let rawValue: String
    }
    
    struct PricePoint: Decodable, Equatable {
        let ident: String
        let services: [Feature]
        let currencyCode: String
        let nextTotalPrice: String
    }
    
    struct Feature: Decodable, Equatable {
        let featureIdent: String
    }
    
    let id: UUID
    let state: State
    let createdAt: Date
    let canceledAt: Date?
    let currentPeriodStartAt: Date
    let currentPeriodEndAt: Date
    let nextSubscriptionId: UUID?
    let pricePoint: PricePoint
    let tags: [Tag]
}

extension SubscriptionInternal.Tag {
    static let trial = SubscriptionInternal.Tag(rawValue: "trial")
}
