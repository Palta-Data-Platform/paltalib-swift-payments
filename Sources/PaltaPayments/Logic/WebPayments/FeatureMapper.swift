//
//  FeatureMapper.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation

protocol FeatureMapper {
    func map(_ features: [FeatureInternal], and subscriptions: [SubscriptionInternal]) -> [PaidFeature]
}

final class FeatureMapperImpl: FeatureMapper {
    func map(_ features: [FeatureInternal], and subscriptions: [SubscriptionInternal]) -> [PaidFeature] {
        let subscriptionById = Dictionary
            .init(grouping: subscriptions, by: { $0.id })
            .compactMapValues { $0.first }
        
        return features.map {
            PaidFeature(
                name: $0.feature,
                productIdentifier: nil,
                pricePointIdent: $0.lastSubscriptionId.flatMap { subscriptionById[$0] }?.pricePoint.ident,
                paymentType: $0.paymentType(subscriptions: subscriptionById),
                transactionType: .web
            )
        }
    }
}

private extension FeatureInternal {
    func paymentType(subscriptions: [UUID: SubscriptionInternal]) -> PaidFeature.PaymentType {
        lastSubscriptionId
            .flatMap { subscriptions[$0] }
            .map {
                .subscription($0.subscriptions(subscriptions: subscriptions))
            }
        ?? .oneOff
    }
    
    func isTrial(subscriptions: [UUID: SubscriptionInternal]) -> Bool {
        lastSubscriptionId.flatMap { subscriptions[$0]?.tags.contains(.trial) } ?? false
    }
    
    func cancellationDate(subscriptions: [UUID: SubscriptionInternal]) -> Date? {
        lastSubscriptionId.flatMap { subscriptions[$0]?.canceledAt }
    }
}
                    
extension SubscriptionInternal {
    func subscriptions(subscriptions: [UUID: SubscriptionInternal]) -> PaidFeature.Subscriptions {
        .init(
            current: .init(
                startDate: currentPeriodStartAt,
                endDate: currentPeriodEndAt,
                cancellationDate: canceledAt,
                cancellationToken: nil,
                isTrial: tags.contains(.trial),
                isIntroductory: false
            ),
            next: nextSubscriptionId.flatMap { subscriptions[$0] }?.subscriptions(subscriptions: [:]).current
        )
    }
}
