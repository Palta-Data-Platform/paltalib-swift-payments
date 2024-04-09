//
//  PBPurchasePluginTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
import XCTest
@testable import PaltaPayments

final class PBPurchasePluginTests: XCTestCase {
    var assemblyMock: PaymentsAssemblyMock!
    
    var plugin: PBPurchasePlugin!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        assemblyMock = .init()
        
        plugin = PBPurchasePlugin(assembly: assemblyMock)
    }
    
    func testLogInLogOut() {
        let userId = UserId.uuid(UUID())
        let successCalled = expectation(description: "Success called")
        
        plugin.logIn(appUserId: userId) {
            guard case .success = $0 else {
                return
            }
            
            successCalled.fulfill()
        }
        
        wait(for: [successCalled], timeout: 0.1)
        
        XCTAssertEqual(plugin.userId, userId)
        
        plugin.logOut()
        
        XCTAssertNil(plugin.userId)
    }
    
    func testGetPaidServicesSuccess() {
        let userId = UserId.uuid(UUID())
        let expectedFeatures = PaidFeatures(features: [.init(name: "name", startDate: Date())])
        assemblyMock.paidFeaturesMock.result = .success(expectedFeatures)
        
        let completionCalled = expectation(description: "Success called")
        
        plugin.logIn(appUserId: userId, completion: { _ in })
        plugin.getPaidFeatures { result in
            guard case let .success(features) = result else {
                return
            }
            
            XCTAssertEqual(features, expectedFeatures)
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(assemblyMock.paidFeaturesMock.userId, userId)
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetPaidServicesFail() {
        let userId = UserId.uuid(UUID())
        assemblyMock.paidFeaturesMock.result = .failure(.invalidKey)
        
        let completionCalled = expectation(description: "Fail called")
        
        plugin.logIn(appUserId: userId, completion: { _ in })
        plugin.getPaidFeatures { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(assemblyMock.paidFeaturesMock.userId, userId)
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetPaidServicesNoLogin() {
        let completionCalled = expectation(description: "Fail called")
        
        plugin.getPaidFeatures { result in
            guard case let .failure(error) = result, case .noUserId = (error as? PaymentsError) else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetFeaturesSuccess() {
        let userId = UserId.uuid(UUID())
        let expectedFeatures = Features(features: [.init(name: "name", startDate: Date(), endDate: nil)])
        assemblyMock.newFeaturesMock.result = .success(expectedFeatures)
        
        let completionCalled = expectation(description: "Success called")
        
        plugin.logIn(appUserId: userId, completion: { _ in })
        plugin.getFeatures { result in
            guard case let .success(features) = result else {
                return
            }
            
            XCTAssertEqual(features, expectedFeatures)
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(assemblyMock.newFeaturesMock.userId, userId)
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetFeaturesFail() {
        let userId = UserId.uuid(UUID())
        assemblyMock.newFeaturesMock.result = .failure(.invalidKey)
        
        let completionCalled = expectation(description: "Fail called")
        
        plugin.logIn(appUserId: userId, completion: { _ in })
        plugin.getFeatures { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(assemblyMock.newFeaturesMock.userId, userId)
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetFeaturesNoLogin() {
        let completionCalled = expectation(description: "Fail called")
        
        plugin.getFeatures { result in
            guard case let .failure(error) = result, case .noUserId = (error as? PaymentsError) else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
        XCTAssertNil(assemblyMock.newFeaturesMock.userId)
    }
    
    func testGetSubsSuccess() {
        let userId = UserId.uuid(UUID())
        let expectedSubs = [Subscription.mock()]
        assemblyMock.publicSubscriptionsMock.result = .success(expectedSubs)
        
        let completionCalled = expectation(description: "Success called")
        
        plugin.logIn(appUserId: userId, completion: { _ in })
        plugin.getSubscriptions { result in
            guard case let .success(subs) = result else {
                return
            }
            
            XCTAssertEqual(subs.map { $0.id }, expectedSubs.map { $0.id })
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(assemblyMock.publicSubscriptionsMock.userId, userId)
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetSubsFail() {
        let userId = UserId.uuid(UUID())
        assemblyMock.publicSubscriptionsMock.result = .failure(.invalidKey)
        
        let completionCalled = expectation(description: "Fail called")
        
        plugin.logIn(appUserId: userId, completion: { _ in })
        plugin.getSubscriptions { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(assemblyMock.publicSubscriptionsMock.userId, userId)
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetSubsNoLogin() {
        let completionCalled = expectation(description: "Fail called")
        
        plugin.getSubscriptions { result in
            guard case let .failure(error) = result, case .noUserId = (error as? PaymentsError) else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
        XCTAssertNil(assemblyMock.publicSubscriptionsMock.userId)
    }
    
    func testGetWebPPSuccess() {
        let userId = UserId.uuid(UUID())
        let ids: Set<String> = ["id1", "id2"]
        let expectedPPs = [WebPricePoint.mock()]
        assemblyMock.showcaseMock.getPricePointsResult = .success(expectedPPs)
        
        let completionCalled = expectation(description: "Success called")
        
        plugin.logIn(appUserId: userId, completion: { _ in })
        plugin.getWebPricePoints(with: ids) { result in
            guard case let .success(pricePoints) = result else {
                return
            }
            
            XCTAssertEqual(pricePoints, expectedPPs)
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(assemblyMock.showcaseMock.getPricePointsUserId, userId)
        XCTAssertEqual(assemblyMock.showcaseMock.getPricePointsIds, ids)
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetWebPPFail() {
        let userId = UserId.uuid(UUID())
        assemblyMock.showcaseMock.getPricePointsResult = .failure(.invalidKey)
        
        let completionCalled = expectation(description: "Fail called")
        
        plugin.logIn(appUserId: userId, completion: { _ in })
        plugin.getWebPricePoints(with: []) { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(assemblyMock.showcaseMock.getPricePointsUserId, userId)
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testGetWebPPNoLogin() {
        let completionCalled = expectation(description: "Fail called")
        
        plugin.getWebPricePoints(with: []) { result in
            guard case let .failure(error) = result, case .noUserId = (error as? PaymentsError) else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
        XCTAssertNil(assemblyMock.showcaseMock.getPricePointsUserId)
    }
    
    func testGetProductsSuccess() {
        let completionCalled = expectation(description: "Success called")
        let userId = UserId.uuid(UUID())
        let productIds = [UUID().uuidString]
        
        assemblyMock.showcaseMock.getProductsResult = .success([.mock()])
        
        plugin.logIn(appUserId: userId, completion: { _ in })
        
        plugin.getProductsAndPricePoints(with: productIds) { result in
            guard case .success(let products) = result else {
                return
            }
            
            XCTAssertEqual(products.count, 1)
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
        
        XCTAssertEqual(assemblyMock.showcaseMock.getProductsUserId, userId)
        XCTAssertEqual(assemblyMock.showcaseMock.getProductsIds, productIds)
    }
    
    func testGetProductsNoLogin() {
        let completionCalled = expectation(description: "No login called")
        
        assemblyMock.showcaseMock.getProductsResult = .success([.mock()])
        
        plugin.getProductsAndPricePoints(with: [UUID().uuidString]) { result in
            guard case let .failure(error) = result, case .noUserId = (error as? PaymentsError) else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
        
        XCTAssertNil(assemblyMock.showcaseMock.getProductsUserId)
    }
    
    func testGetProductsFail() {
        let completionCalled = expectation(description: "Fail called")
        let userId = UserId.uuid(UUID())
        let productIds = [UUID().uuidString]
        
        assemblyMock.showcaseMock.getProductsResult = .failure(.cancelledByUser)
        
        plugin.logIn(appUserId: userId, completion: { _ in })
        
        plugin.getProductsAndPricePoints(with: productIds) { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
        
        XCTAssertEqual(assemblyMock.showcaseMock.getProductsUserId, userId)
        XCTAssertEqual(assemblyMock.showcaseMock.getProductsIds, productIds)
    }
    
    func testGetOffer() {
        let completionCalled = expectation(description: "Not supported called")
        
        plugin.getPromotionalOffer(for: .mock(), product: .mock()) { result in
            guard case .notSupported = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testPurchase() {
        let completionCalled = expectation(description: "Not supported called")
        
        plugin.purchase(.mock(), with: nil) { result in
            guard case .notSupported = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testPurchaseWebPricePoint() {
        let completionCalled = expectation(description: "Not supported called")
        
        plugin.purchase(.mock(originalEntity: WebPricePoint.mock()), with: nil) { result in
            guard
                case let .failure(error) = result,
                let paymentsError = error as? PaymentsError,
                case .webPaymentsNotSupported = paymentsError
            else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
    }
}
