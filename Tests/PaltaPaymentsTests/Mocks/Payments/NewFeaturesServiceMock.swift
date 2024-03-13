//
//  NewFeaturesServiceMock.swift
//  
//
//  Created by Vyacheslav Beltyukov on 13/03/2024.
//

import Foundation
@testable import PaltaPayments

final class NewFeaturesServiceMock: NewFeaturesService {
    var userId: UserId?
    var result: Result<Features, PaymentsError>?
    
    func getFeatures(
        for userId: UserId,
        completion: @escaping (Result<Features, PaymentsError>) -> Void
    ) {
        self.userId = userId
        
        if let result = result {
            completion(result)
        }
    }
}
