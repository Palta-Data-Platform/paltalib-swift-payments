//
//  WebPricePoint.swift
//  
//
//  Created by Vyacheslav Beltyukov on 14/03/2024.
//

import Foundation

public struct WebPricePoint: Hashable {
    public struct IntroPayment: Hashable {
        public let price: Decimal
        public let period: SubscriptionPeriod
        
        public let currencyCode: String
    }
    
    public struct SubscriptionPayment: Hashable {
        public let introPrice: Decimal
        public let introPeriod: SubscriptionPeriod
        
        public let price: Decimal
        public let period: SubscriptionPeriod
        
        public let currencyCode: String
    }
    
    public struct OneTimePayment: Hashable {
        public let price: Decimal
        public let currencyCode: String
    }
    
    public enum PaymentType: Hashable {
        case intro(IntroPayment)
        case subscription(SubscriptionPayment)
        case oneTime(OneTimePayment)
        case freebie
    }
    
    public let ident: String
    public let name: String
    public let payment: PaymentType
}
