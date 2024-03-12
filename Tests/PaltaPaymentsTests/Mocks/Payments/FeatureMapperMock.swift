//
//  FeatureMapperMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
@testable import PaltaPayments

final class FeatureMapperMock: FeatureMapper {
    var features: [FeatureInternal]?
    var subscriptions: [SubscriptionInternal]?
    
    var result = [PaidFeature(name: "feature", startDate: Date(timeIntervalSince1970: 0))]
    
    func map(_ features: [FeatureInternal], and subscriptions: [SubscriptionInternal]) -> [PaidFeature] {
        self.features = features
        self.subscriptions = subscriptions
        
        return result
    }
}
