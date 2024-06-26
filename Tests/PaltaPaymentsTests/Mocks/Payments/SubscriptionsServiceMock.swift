//
//  SubscriptionsServiceMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
@testable import PaltaPayments

final class SubscriptionsServiceMock: SubscriptionsService {
    var ids: Set<UUID>?
    var userId: UserId?
    var result: Result<[SubscriptionInternal], PaymentsError>?
    
    func getSubscriptions(
        with ids: Set<UUID>?,
        for userId: UserId,
        completion: @escaping (Result<[SubscriptionInternal], PaymentsError>) -> Void
    ) {
        self.ids = ids
        self.userId = userId
        
        if let result = result {
            completion(result)
        }
    }
}
