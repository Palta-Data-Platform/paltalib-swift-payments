//
//  Product.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 08.05.2022.
//

import Foundation

public enum ProductType: Hashable {
    /// A consumable in-app purchase.
    case consumable

    /// A non-consumable in-app purchase.
    case nonConsumable

    /// A non-renewing subscription.
    case nonRenewableSubscription

    /// An auto-renewable subscription.
    case autoRenewableSubscription
}

public struct SubscriptionPeriod: Hashable {
    public enum Unit: Int, Hashable {
        /// A subscription period unit of a second.
        case second = -2
        /// A subscription period unit of a minute.
        case minute = -1
        /// A subscription period unit of a day.
        case day = 0
        /// A subscription period unit of a week.
        case week = 1
        /// A subscription period unit of a month.
        case month = 2
        /// A subscription period unit of a year.
        case year = 3
    }

    /// The number of period units.
    public let value: Int
    /// The increment of time that a subscription period is specified in.
    public let unit: Unit
}

public struct Product {
    public let productType: ProductType
    public let productIdentifier: String
    public let localizedDescription: String
    public let localizedTitle: String
    public let currencyCode: String?
    public let price: Decimal
    public let localizedPriceString: String
    public let formatter: NumberFormatter
    
    public let subscriptionPeriod: SubscriptionPeriod?
    public let introductoryDiscount: ProductDiscount?
    public let discounts: [ProductDiscount]
    
    let originalEntity: Any
}

extension Product: Hashable {
    public static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.productType == rhs.productType
        && lhs.productIdentifier == rhs.productIdentifier
        && lhs.localizedDescription == rhs.localizedDescription
        && lhs.localizedTitle == rhs.localizedTitle
        && lhs.currencyCode == rhs.currencyCode
        && lhs.price == rhs.price
        && lhs.subscriptionPeriod == rhs.subscriptionPeriod
        && lhs.introductoryDiscount == rhs.introductoryDiscount
        && lhs.discounts == rhs.discounts
    }
    
    public func hash(into hasher: inout Hasher) {
        productType.hash(into: &hasher)
        productIdentifier.hash(into: &hasher)
        localizedDescription.hash(into: &hasher)
        localizedTitle.hash(into: &hasher)
        currencyCode.hash(into: &hasher)
        price.hash(into: &hasher)
        subscriptionPeriod.hash(into: &hasher)
        introductoryDiscount?.hashValue.hash(into: &hasher)
        
        discounts.forEach {
            $0.hashValue.hash(into: &hasher)
        }
    }
}
