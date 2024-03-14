//
//  PublicSubscriptionsService.swift
//  
//
//  Created by Vyacheslav Beltyukov on 13/03/2024.
//

import Foundation

protocol PublicSubscriptionsService {
    func getSubscriptions(
        for userId: UserId,
        completion: @escaping (Result<[Subscription], PaymentsError>) -> Void
    )
}

final class PublicSubscriptionsServiceImpl: PublicSubscriptionsService {
    private let subscriptionsService: SubscriptionsService
    
    init(subscriptionsService: SubscriptionsService) {
        self.subscriptionsService = subscriptionsService
    }
    
    func getSubscriptions(
        for userId: UserId,
        completion: @escaping (Result<[Subscription], PaymentsError>) -> Void
    ) {
        subscriptionsService.getSubscriptions(with: nil, for: userId) { [weak self] result in
            switch result {
            case let .success(subscriptions):
                self?.process(subscriptions, to: completion)
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func process(
        _ subscriptions: [SubscriptionInternal],
        to completion: @escaping (Result<[Subscription], PaymentsError>) -> Void
    ) {
        let mappedSubscriptions = subscriptions.map(mapSubscription)
        
        let subscOriginalMap = Dictionary
            .init(grouping: subscriptions, by: { $0.id })
            .compactMapValues { $0.first }
        
        let subscFinalMap = Dictionary
            .init(grouping: mappedSubscriptions, by: { $0.id })
            .compactMapValues { $0.first }
        
        mappedSubscriptions.forEach {
            $0.next = subscOriginalMap[$0.id]?.nextSubscriptionId.flatMap { subscFinalMap[$0] }
        }
        
        mappedSubscriptions.forEach(checkForCycleRefs)
        
        completion(.success(mappedSubscriptions))
    }
                
    private func mapSubscription(
        _ subscription: SubscriptionInternal
    ) -> Subscription {
        let state = Subscription.State.init(subscription.state)
        
        return Subscription(
            id: subscription.id,
            productIdentifier: subscription.pricePoint.ident,
            startDate: subscription.currentPeriodStartAt,
            endDate: subscription.currentPeriodEndAt,
            state: state,
            type: .web,
            price: Decimal(string: subscription.pricePoint.nextTotalPrice, locale: Locale(identifier: "en-US")) ?? 0,
            currencyCode: subscription.pricePoint.currencyCode,
            period: .init(value: 0, unit: .day),
            providedFeatures: subscription.pricePoint.services.map { $0.featureIdent },
            next: nil
        )
    }
    
    private func checkForCycleRefs(_ subscription: Subscription) {
        var ids: Set<UUID> = []
        var subscription = subscription
        
        while let next = subscription.next {
            ids.insert(subscription.id)
            
            if ids.contains(next.id) {
                subscription.next = nil
                return
            } else {
                subscription = next
            }
        }
    }
}

fileprivate extension Subscription.State {
    init(_ apiState: SubscriptionInternal.State) {
        switch apiState {
        case .new:
            self = .active
        case .active:
            self = .active
        case .cancelled:
            self = .cancelled
        case .upcoming:
            self = .upcoming
        }
    }
}
