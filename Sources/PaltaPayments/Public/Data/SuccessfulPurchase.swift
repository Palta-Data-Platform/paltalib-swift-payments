//
//  SuccessfulPurchase.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import Foundation

@available(*, deprecated, message: "Use SuccessfulPurchase2 instead")
public struct SuccessfulPurchase {
    public let transaction: Transaction
    public let paidFeatures: PaidFeatures
    
    public init(transaction: Transaction, paidFeatures: PaidFeatures) {
        self.transaction = transaction
        self.paidFeatures = paidFeatures
    }
}

public struct SuccessfulPurchase2 {
    public let transaction: Transaction
    public let features: Features
    
    public init(transaction: Transaction, features: Features) {
        self.transaction = transaction
        self.features = features
    }
}
