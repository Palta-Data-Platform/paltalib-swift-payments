//
//  PBLegacyRestoreRequestData.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 20/01/2023.
//

import Foundation

struct PBLegacyRestoreRequestData: Encodable {
    enum CodingKeys: String, CodingKey {
        case email
        case webSubscriptionID = "web_subscription_id"
    }

    let email: String
    let webSubscriptionID: String
}
