//
//  NewFeaturesService.swift
//  
//
//  Created by Vyacheslav Beltyukov on 13/03/2024.
//

import Foundation

protocol NewFeaturesService {
    func getFeatures(
        for userId: UserId,
        completion: @escaping (Result<Features, PaymentsError>) -> Void
    )
}

final class NewFeaturesServiceImpl: NewFeaturesService {
    private let featuresService: FeaturesService
    
    init(
        featuresService: FeaturesService
    ) {
        self.featuresService = featuresService
    }
    
    func getFeatures(
        for userId: UserId,
        completion: @escaping (Result<Features, PaymentsError>) -> Void
    ) {
        featuresService.getFeatures(for: userId) { [weak self] result in
            switch result {
            case .success(let features):
                self?.completeFeaturesRequest(with: features, completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func completeFeaturesRequest(with response: [FeatureInternal], completion: @escaping (Result<Features, PaymentsError>) -> Void) {
        completion(
            .success(
                Features(
                    features: response.map {
                        Feature(
                            name: $0.feature,
                            startDate: $0.actualFrom,
                            endDate: $0.actualTill
                        )
                    }
                )
            )
        )
    }
}
