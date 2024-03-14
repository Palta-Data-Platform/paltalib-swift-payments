//
//  WebPaymentsAssembly.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
import PaltaCore

final class WebPaymentsAssembly {
    @available(*, deprecated, message: "")
    let paidFeaturesService: PaidFeaturesService
    
    let newFeaturesService: NewFeaturesService
    let publicSubscriptionsService: PublicSubscriptionsService
    
    @available(*, deprecated, message: "")
    private init(
        paidFeaturesService: PaidFeaturesService,
        newFeaturesService: NewFeaturesService,
        publicSubscriptionsService: PublicSubscriptionsService
    ) {
        self.paidFeaturesService = paidFeaturesService
        self.newFeaturesService = newFeaturesService
        self.publicSubscriptionsService = publicSubscriptionsService
    }
}

extension WebPaymentsAssembly {
    @available(*, deprecated, message: "")
    convenience init(apiKey: String, environment: Environment, coreAssembly: CoreAssembly) {
        coreAssembly.httpClient.mandatoryHeaders = ["x-api-key": apiKey]

        let featureMapper = FeatureMapperImpl()
        let featuresService = FeaturesServiceImpl(environment: environment, httpClient: coreAssembly.httpClient)
        let subscriptionsService = SubscriptionsServiceImpl(environment: environment, httpClient: coreAssembly.httpClient)
        
        let paidFeaturesService: PaidFeaturesService = PaidFeaturesServiceImpl(
            subscriptionsService: subscriptionsService,
            featuresService: featuresService,
            featureMapper: featureMapper
        )
        
        let newFeaturesService = NewFeaturesServiceImpl(featuresService: featuresService)
        let publicSubscriptionsService = PublicSubscriptionsServiceImpl(subscriptionsService: subscriptionsService)
        
        self.init(
            paidFeaturesService: paidFeaturesService,
            newFeaturesService: newFeaturesService,
            publicSubscriptionsService: publicSubscriptionsService
        )
    }
}
