//
//  PaymentsAssembly.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
import PaltaCore

protocol PaymentsAssembly {
    var paidFeaturesService: PaidFeaturesService { get }
    
    var newFeaturesService: NewFeaturesService { get }
    var publicSubscriptionsService: PublicSubscriptionsService { get }
    var showcaseService: ShowcaseService { get }
}

final class RealPaymentsAssembly: PaymentsAssembly {
    var paidFeaturesService: PaidFeaturesService {
        webPaymentsAssembly.paidFeaturesService
    }
    
    var newFeaturesService: NewFeaturesService {
        webPaymentsAssembly.newFeaturesService
    }
    
    var publicSubscriptionsService: PublicSubscriptionsService {
        webPaymentsAssembly.publicSubscriptionsService
    }
    
    var showcaseService: ShowcaseService {
        webPaymentsAssembly.showcaseService
    }
    
    private let coreAssembly: CoreAssembly
    private let webPaymentsAssembly: WebPaymentsAssembly
    
    private init(coreAssembly: CoreAssembly, webPaymentsAssembly: WebPaymentsAssembly) {
        self.coreAssembly = coreAssembly
        self.webPaymentsAssembly = webPaymentsAssembly
    }
}

extension RealPaymentsAssembly {
    convenience init(apiKey: String, environment: Environment) {
        let core = CoreAssembly()
        let webPayments = WebPaymentsAssembly(apiKey: apiKey, environment: environment, coreAssembly: core)
        
        self.init(coreAssembly: core, webPaymentsAssembly: webPayments)
    }
}
