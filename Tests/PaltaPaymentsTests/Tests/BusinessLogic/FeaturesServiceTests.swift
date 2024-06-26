//
//  FeaturesServiceTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
import XCTest
@testable import PaltaPayments

final class FeaturesServiceTests: XCTestCase {
    var service: FeaturesServiceImpl!
    var httpMock: HTTPClientMock!
    var environment: Environment!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        httpMock = .init()
        environment = URL(string: "https://mock.mock/\(UUID())")
        service = .init(environment: environment, httpClient: httpMock)
    }
    
    func testSuccess() {
        let uuid = UUID()
        let expectedFeatures = [FeatureInternal.mock()]
        let completionCalled = expectation(description: "Success called")
        
        httpMock.result = .success(FeaturesResponse(features: expectedFeatures))
        
        service.getFeatures(for: .uuid(uuid)) { result in
            guard case let .success(features) = result else {
                return
            }
            
            XCTAssertEqual(features, expectedFeatures)
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest), .getFeatures(environment, .uuid(uuid)))
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testFail() {
        let uuid = UUID()
        let expectedFeatures = [FeatureInternal.mock()]
        let completionCalled = expectation(description: "Fail called")
        
        httpMock.result = .success(FeaturesResponse(features: expectedFeatures))
        
        service.getFeatures(for: .uuid(uuid)) { result in
            guard case let .success(features) = result else {
                return
            }
            
            XCTAssertEqual(features, expectedFeatures)
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual((httpMock.request as? PaymentsHTTPRequest), .getFeatures(environment, .uuid(uuid)))
        
        wait(for: [completionCalled], timeout: 0.1)
    }
}
