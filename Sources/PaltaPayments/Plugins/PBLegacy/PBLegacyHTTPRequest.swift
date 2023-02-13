//
//  PBLegacyHTTPRequest.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 20/01/2023.
//

import Foundation
import PaltaCore

enum PBLegacyHTTPRequest {
    case restoreSubscription(PBLegacyRestoreRequestData)
    case cancelSubscription(PBLegacyCancelRequestData)
}

extension PBLegacyHTTPRequest: CodableAutobuildingHTTPRequest {
    var baseURL: URL {
        URL(string: "https://ws.prod.paltabrain.com")!
    }

    var method: HTTPMethod {
        switch self {
        case .restoreSubscription, .cancelSubscription:
            return .post
        }
    }

    var headers: [String : String]? {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }

    var path: String? {
        switch self {
        case .restoreSubscription:
            return "/v1/send-restore-subscription-email"
        case .cancelSubscription:
            return "/v1/unsubscribe"
        }
    }

    var bodyObject: AnyEncodable? {
        switch self {
        case .restoreSubscription(let restoreRequestData):
            return restoreRequestData.typeErased
        case .cancelSubscription(let cancelRequestData):
            return cancelRequestData.typeErased
        }
    }

}

