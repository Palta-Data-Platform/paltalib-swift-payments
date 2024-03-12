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
    }
    
    struct Tag: RawRepresentable, Decodable, Equatable {
        typealias RawValue = String
        
        let rawValue: String
    }
    
    let id: UUID
    let state: State
    let createdAt: Date
    let canceledAt: Date?
    let currentPeriodStartAt: Date
    let currentPeriodEndAt: Date
    let tags: [Tag]
}

extension SubscriptionInternal.Tag {
    static let trial = SubscriptionInternal.Tag(rawValue: "trial")
}
