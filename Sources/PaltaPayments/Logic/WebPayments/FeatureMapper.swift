//
//  FeatureMapper.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation

@available(*, deprecated, message: "Use Feature instead")
protocol FeatureMapper {
    func map(_ features: [FeatureInternal], and subscriptions: [SubscriptionInternal]) -> [PaidFeature]
}

@available(*, deprecated, message: "Use Feature instead")
final class FeatureMapperImpl: FeatureMapper {
    func map(_ features: [FeatureInternal], and subscriptions: [SubscriptionInternal]) -> [PaidFeature] {
        let subscriptionById = Dictionary
            .init(grouping: subscriptions, by: { $0.id })
            .compactMapValues { $0.first }
        
        return features.map {
            PaidFeature(
                name: $0.feature,
                productIdentifier: nil,
                paymentType: $0.paymentType(subscriptions: subscriptionById),
                transactionType: .web,
                isTrial: $0.isTrial(subscriptions: subscriptionById),
                isIntroductory: false, // TODO: Use API data
                willRenew: false, // TODO: Use API data
                startDate: $0.actualFrom,
                endDate: $0.actualTill,
                cancellationDate: $0.cancellationDate(subscriptions: subscriptionById),
                cancellationToken: nil
            )
        }
    }
}

@available(*, deprecated, message: "Use Feature instead")
private extension FeatureInternal {
    func paymentType(subscriptions: [UUID: SubscriptionInternal]) -> PaidFeature.PaymentType {
        lastSubscriptionId.flatMap { subscriptions[$0] } != nil ? .subscription : .oneOff
    }
    
    func isTrial(subscriptions: [UUID: SubscriptionInternal]) -> Bool {
        lastSubscriptionId.flatMap { subscriptions[$0]?.tags.contains(.trial) } ?? false
    }
    
    func cancellationDate(subscriptions: [UUID: SubscriptionInternal]) -> Date? {
        lastSubscriptionId.flatMap { subscriptions[$0]?.canceledAt }
    }
}
