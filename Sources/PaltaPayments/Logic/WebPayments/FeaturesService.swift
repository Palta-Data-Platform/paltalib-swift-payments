//
//  FeaturesService.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
import PaltaCore

protocol FeaturesService {
    func getFeatures(for userId: UserId, completion: @escaping (Result<[FeatureInternal], PaymentsError>) -> Void)
}

final class FeaturesServiceImpl: FeaturesService {
    private let environment: Environment
    private let httpClient: HTTPClient
    
    init(environment: Environment, httpClient: HTTPClient) {
        self.environment = environment
        self.httpClient = httpClient
    }
    
    func getFeatures(for userId: UserId, completion: @escaping (Result<[FeatureInternal], PaymentsError>) -> Void) {
        let request = PaymentsHTTPRequest.getFeatures(environment, userId)
        
        httpClient.perform(request) { (result: Result<FeaturesResponse, NetworkErrorWithoutResponse>) in
            switch result {
            case .success(let response):
                completion(.success(response.features))
                
            case .failure(let error):
                completion(.failure(PaymentsError(networkError: error)))
            }
        }
    }
}
