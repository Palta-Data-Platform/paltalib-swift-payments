//
//  PBLegacyCancelRequestData.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 20/01/2023.
//

import Foundation

struct PBLegacyCancelRequestData: Encodable {
    enum CodingKeys: String, CodingKey {
        case revenueCatID = "revenue_cat_id"
        case webSubscriptionID = "web_subscription_id"
    }

    let revenueCatID: String
    let webSubscriptionID: String
}
