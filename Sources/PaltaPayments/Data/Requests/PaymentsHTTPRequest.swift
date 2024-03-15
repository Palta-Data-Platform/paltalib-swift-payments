//
//  PaymentsHTTPRequest.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
import PaltaCore

enum PaymentsHTTPRequest: Equatable {
    case getFeatures(Environment, UserId)
    case getSubcriptions(Environment, UserId, Set<UUID>?)
    case getPricePoints(Environment, UserId, Set<String>)
}

extension PaymentsHTTPRequest: CodableAutobuildingHTTPRequest {
    var environment: Environment {
        switch self {
        case .getFeatures(let environemt, _):
            return environemt
        case .getSubcriptions(let environemt, _, _):
            return environemt
        case .getPricePoints(let environment, _, _):
            return environment
        }
    }
    var bodyObject: AnyEncodable? {
        switch self {
        case let .getFeatures(_, userId):
            return GetFeaturesRequestPayload(customerId: userId).typeErased
            
        case let .getSubcriptions(_, userId, subscriptionIds):
            return GetSubscriptionsRequestPayload(customerId: userId, onlyIds: subscriptionIds).typeErased
            
        case let .getPricePoints(_, userId, ids):
            return GetPricePointsPayload(customerId: userId, ident: ids).typeErased
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getSubcriptions, .getFeatures, .getPricePoints:
            return .post
        }
    }
    
    var baseURL: URL {
        environment
    }
    
    var path: String? {
        switch self {
        case .getFeatures:
            return "/feature-provisioner/get-features"
            
        case .getSubcriptions:
            return "/subscriptions-tracker/get-subscriptions"
            
        case .getPricePoints:
            return "/showcase/get-price-points"
        }
    }
}
