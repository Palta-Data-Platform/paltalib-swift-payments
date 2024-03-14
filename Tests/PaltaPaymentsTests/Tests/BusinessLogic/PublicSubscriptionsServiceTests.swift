//
//  PublicSubscriptionsServiceTests.swift
//  
//
//  Created by Vyacheslav Beltyukov on 14/03/2024.
//

import Foundation
import XCTest
@testable import PaltaPayments

final class PublicSubscriptionsServiceTests: XCTestCase {
    var subscriptionsMock: SubscriptionsServiceMock!
    
    var service: PublicSubscriptionsServiceImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        subscriptionsMock = .init()
        
        service = PublicSubscriptionsServiceImpl(subscriptionsService: subscriptionsMock)
    }
    
    func testSuccess() {
        let subscriptionId = UUID()
        let subscriptions = [
            SubscriptionInternal.mock(id: subscriptionId)
        ]
        subscriptionsMock.result = .success(subscriptions)
        let userId = UserId.uuid(UUID())
        
        let expectedSubscription = Subscription(
            id: subscriptionId,
            productIdentifier: "ident1",
            startDate: Date(timeIntervalSince1970: 6),
            endDate: Date(timeIntervalSince1970: 18),
            state: .active,
            type: .web,
            price: 990.98,
            currencyCode: "USD",
            providedFeatures: ["feature1"],
            next: nil
        )
        
        let completionCalled = expectation(description: "Success completion called")
        
        service.getSubscriptions(for: userId) { result in
            guard case let .success(subscriptions) = result else {
                return
            }
            
            XCTAssertEqual(subscriptions.first?.productIdentifier, expectedSubscription.productIdentifier)
            XCTAssertEqual(subscriptions.first?.startDate, expectedSubscription.startDate)
            XCTAssertEqual(subscriptions.first?.endDate, expectedSubscription.endDate)
            XCTAssertEqual(subscriptions.first?.state, expectedSubscription.state)
            XCTAssertEqual(subscriptions.first?.type, expectedSubscription.type)
            XCTAssertEqual(subscriptions.first?.price, expectedSubscription.price)
            XCTAssertEqual(subscriptions.first?.currencyCode, expectedSubscription.currencyCode)
            XCTAssertEqual(subscriptions.first?.providedFeatures, expectedSubscription.providedFeatures)
            XCTAssertNil(subscriptions.first?.next)
            
            XCTAssertEqual(subscriptions.count, 1)
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(subscriptionsMock.userId, userId)
        XCTAssertEqual(subscriptionsMock.ids, nil)
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testSuccessWithNextSubscription() {
        let subscriptionId1 = UUID()
        let subscriptionId2 = UUID()
        
        let subscriptions = [
            SubscriptionInternal.mock(ident: "ident1", id: subscriptionId1, nextId: subscriptionId2),
            SubscriptionInternal.mock(ident: "ident2", id: subscriptionId2)
        ]
        
        subscriptionsMock.result = .success(subscriptions)
        let userId = UserId.uuid(UUID())
        
        let completionCalled = expectation(description: "Success completion called")
        
        service.getSubscriptions(for: userId) { result in
            guard case let .success(subscriptions) = result else {
                return
            }
            
            XCTAssertEqual(subscriptions.first?.productIdentifier, "ident1")
            XCTAssertEqual(subscriptions.last?.productIdentifier, "ident2")
            XCTAssertEqual(subscriptions.first?.next?.productIdentifier, "ident2")
            XCTAssertNil(subscriptions.last?.next)
            
            XCTAssert(subscriptions.first?.next === subscriptions.last)
            
            XCTAssertEqual(subscriptions.count, 2)
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(subscriptionsMock.userId, userId)
        XCTAssertEqual(subscriptionsMock.ids, nil)
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testSuccessWithCycleSubscription() {
        let subscriptionId1 = UUID()
        let subscriptionId2 = UUID()
        
        let subscriptions = [
            SubscriptionInternal.mock(ident: "ident1", id: subscriptionId1, nextId: subscriptionId2),
            SubscriptionInternal.mock(ident: "ident2", id: subscriptionId2, nextId: subscriptionId1)
        ]
        
        subscriptionsMock.result = .success(subscriptions)
        let userId = UserId.uuid(UUID())
        
        let completionCalled = expectation(description: "Success completion called")
        
        service.getSubscriptions(for: userId) { result in
            guard case let .success(subscriptions) = result else {
                return
            }
            
            XCTAssertEqual(subscriptions.first?.productIdentifier, "ident1")
            XCTAssertEqual(subscriptions.last?.productIdentifier, "ident2")
            XCTAssertEqual(subscriptions.first?.next?.productIdentifier, "ident2")
            XCTAssertNil(subscriptions.last?.next)
            
            XCTAssertEqual(subscriptions.count, 2)
            
            completionCalled.fulfill()
        }
        
        XCTAssertEqual(subscriptionsMock.userId, userId)
        XCTAssertEqual(subscriptionsMock.ids, nil)
        
        wait(for: [completionCalled], timeout: 0.1)
    }
    
    func testFail() {
        subscriptionsMock.result = .failure(.networkError(URLError(.notConnectedToInternet)))
        let userId = UserId.uuid(UUID())
        
        let completionCalled = expectation(description: "Fail completion called")
        
        service.getSubscriptions(for: userId) { result in
            guard case .failure = result else {
                return
            }
            
            completionCalled.fulfill()
        }
        
        wait(for: [completionCalled], timeout: 0.1)
    }
}
