//
//  PublicSubscriptionsServiceMock.swift
//  
//
//  Created by Vyacheslav Beltyukov on 14/03/2024.
//

import Foundation
@testable import PaltaPayments

final class PublicSubscriptionsServiceMock: PublicSubscriptionsService {
    var userId: UserId?
    var result: Result<[Subscription], PaymentsError>?
    
    func getSubscriptions(
        for userId: UserId,
        completion: @escaping (Result<[Subscription], PaymentsError>) -> Void
    ) {
        self.userId = userId
        
        if let result = result {
            completion(result)
        }
    }
}
