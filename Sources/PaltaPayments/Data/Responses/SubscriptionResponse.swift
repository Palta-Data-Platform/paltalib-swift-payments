//
//  SubscriptionResponse.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation

struct SubscriptionResponse: Decodable {
    let subscriptions: [SubscriptionInternal]
}
