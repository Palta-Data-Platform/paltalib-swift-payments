//
//  SubscriptionsService.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
import PaltaCore

protocol SubscriptionsService {
    func getSubscriptions(
        with ids: Set<UUID>?,
        for userId: UserId,
        completion: @escaping (Result<[SubscriptionInternal], PaymentsError>) -> Void
    )
}

final class SubscriptionsServiceImpl: SubscriptionsService {
    private let environment: Environment
    private let httpClient: HTTPClient
    
    init(environment: Environment, httpClient: HTTPClient) {
        self.environment = environment
        self.httpClient = httpClient
    }
    
    func getSubscriptions(
        with ids: Set<UUID>?,
        for userId: UserId,
        completion: @escaping (Result<[SubscriptionInternal], PaymentsError>) -> Void
    ) {
        let request = PaymentsHTTPRequest.getSubcriptions(environment, userId, ids)
        
        httpClient.perform(request) { (result: Result<SubscriptionResponse, NetworkErrorWithoutResponse>) in
            switch result {
            case .success(let response):
                completion(.success(response.subscriptions))
                
            case .failure(let error):
                completion(.failure(PaymentsError(networkError: error)))
            }
        }
    }
}
