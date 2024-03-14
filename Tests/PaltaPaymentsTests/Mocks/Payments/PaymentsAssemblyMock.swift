//
//  PaymentsAssemblyMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
@testable import PaltaPayments

final class PaymentsAssemblyMock: PaymentsAssembly {
    let newFeaturesMock = NewFeaturesServiceMock()
    let paidFeaturesMock = PaidFeaturesServiceMock()
    let publicSubscriptionsMock = PublicSubscriptionsServiceMock()
    
    var paidFeaturesService: PaidFeaturesService {
        paidFeaturesMock
    }
    
    var newFeaturesService: NewFeaturesService {
        newFeaturesMock
    }
    
    var publicSubscriptionsService: PublicSubscriptionsService {
        publicSubscriptionsMock
    }
}
