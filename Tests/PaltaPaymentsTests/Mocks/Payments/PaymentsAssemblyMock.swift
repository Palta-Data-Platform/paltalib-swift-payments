//
//  PaymentsAssemblyMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
@testable import PaltaPayments

final class PaymentsAssemblyMock: PaymentsAssembly {
    let newFeaturesMock = NewFeaturesServiceImpl(featuresService: FeaturesServiceMock())
    let paidFeaturesMock = PaidFeaturesServiceMock()
    
    var paidFeaturesService: PaidFeaturesService {
        paidFeaturesMock
    }
    
    var newFeaturesService: NewFeaturesService {
        newFeaturesMock
    }
}
