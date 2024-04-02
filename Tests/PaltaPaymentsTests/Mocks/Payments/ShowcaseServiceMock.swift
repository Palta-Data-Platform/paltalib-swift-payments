//
//  ShowcaseServiceMock.swift
//  
//
//  Created by Vyacheslav Beltyukov on 19/03/2024.
//

import Foundation
@testable import PaltaPayments

final class ShowcaseServiceMock: ShowcaseService {
    var getPricePointsResult: Result<[WebPricePoint], PaymentsError>?
    var getPricePointsIds: Set<String>?
    var getPricePointsUserId: UserId?
    
    var getProductsResult: Result<Set<Product>, PaymentsError>?
    var getProductsIds: [String]?
    var getProductsUserId: UserId?
    
    func getPricePoints(
        with ids: Set<String>,
        for userId: UserId,
        completion: @escaping (Result<[WebPricePoint], PaymentsError>) -> Void
    ) {
        self.getPricePointsIds = ids
        self.getPricePointsUserId = userId
    
        if let getPricePointsResult {
            completion(getPricePointsResult)
        }
    }
    
    func getProducts(
        with ids: [String],
        for userId: UserId,
        completion: @escaping (Result<Set<Product>, PaymentsError>) -> Void
    ) {
        self.getProductsIds = ids
        self.getProductsUserId = userId
    
        if let getProductsResult {
            completion(getProductsResult)
        }
    }
}
