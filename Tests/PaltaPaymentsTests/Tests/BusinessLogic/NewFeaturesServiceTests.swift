//
//  NewFeaturesServiceTests.swift
//  
//
//  Created by Vyacheslav Beltyukov on 13/03/2024.
//

import Foundation
import XCTest
@testable import PaltaPayments

final class NewFeaturesServiceTests: XCTestCase {
    var featuresMock: FeaturesServiceMock!
    
    var service: NewFeaturesServiceImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        featuresMock = .init()
        
        service = NewFeaturesServiceImpl(
            featuresService: featuresMock
        )
    }
    
    func testSuccess() {
        featuresMock.result = .success([.mock(lastSubscriptionId: UUID())])
        let userId = UserId.uuid(UUID())
        let expectedFeatures = Features(features: [
            Feature(
                name: "sku-mock",
                startDate: Date(timeIntervalSince1970: 0),
                endDate: Date(timeIntervalSince1970: 100)
            )
        ])
        
        let completionCalled = expectation(description: "Success completion called")
        
        service.getFeatures(for: userId) { result in
            guard case let .success(features) = result else {
                return
            }
            
            XCTAssertEqual(features, expectedFeatures)
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(featuresMock.userId, userId)
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testFail() {
        featuresMock.result = .failure(.invalidKey)
        let userId = UserId.uuid(UUID())
        
        let completionCalled = expectation(description: "Fail completion called")
        
        service.getFeatures(for: userId) { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(featuresMock.userId, userId)
        
        wait(for: [completionCalled], timeout: 0.1)
    }
}
