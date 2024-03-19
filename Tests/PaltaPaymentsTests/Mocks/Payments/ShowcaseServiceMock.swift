//
//  ShowcaseServiceMock.swift
//  
//
//  Created by Vyacheslav Beltyukov on 19/03/2024.
//

import Foundation
@testable import PaltaPayments

final class ShowcaseServiceMock: ShowcaseService {
    var result: Result<[WebPricePoint], PaymentsError>?
    var ids: Set<String>?
    var userId: UserId?
    
    func getPricePoints(
        with ids: Set<String>,
        for userId: UserId,
        completion: @escaping (Result<[WebPricePoint], PaymentsError>) -> Void
    ) {
        self.ids = ids
        self.userId = userId
    
        if let result {
            completion(result)
        }
    }
}
