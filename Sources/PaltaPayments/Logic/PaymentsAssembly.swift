//
//  PaymentsAssembly.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
import PaltaCore

protocol PaymentsAssembly {
    @available(*, deprecated, message: "Use `newFeaturesService` instead")
    var paidFeaturesService: PaidFeaturesService { get }
    
    var newFeaturesService: NewFeaturesService { get }
}

final class RealPaymentsAssembly: PaymentsAssembly {
    @available(*, deprecated, message: "Use `newFeaturesService` instead")
    var paidFeaturesService: PaidFeaturesService {
        webPaymentsAssembly.paidFeaturesService
    }
    
    var newFeaturesService: NewFeaturesService {
        webPaymentsAssembly.newFeaturesService
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
