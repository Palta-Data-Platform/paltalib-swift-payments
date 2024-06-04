//
//  FeatureMapperTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
@testable import PaltaPayments
import XCTest

final class FeatureMapperTests: XCTestCase {
    var mapper: FeatureMapperImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mapper = FeatureMapperImpl()
    }
    
    func testBaseMapping() {
        let features = [
            FeatureInternal(
                quantity: 1,
                actualFrom: Date(timeIntervalSince1970: 0),
                actualTill: Date(timeIntervalSince1970: 100),
                feature: "sku1",
                lastSubscriptionId: nil
            )
        ]
        
        let paidFeatures = mapper.map(features, and: [])
        
        XCTAssertEqual(paidFeatures.first?.name, "sku1")
        
        guard case .oneOff = paidFeatures.first?.paymentType else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(paidFeatures.first?.paymentType, .oneOff)
        XCTAssertEqual(paidFeatures.first?.transactionType, .web)
        XCTAssertNil(paidFeatures.first?.productIdentifier)
    }
    
    func testTrial() {
        let subscriptionId = UUID()
        
        let features = [
            FeatureInternal(
                quantity: 1,
                actualFrom: Date(timeIntervalSince1970: 0),
                actualTill: Date(timeIntervalSince1970: 100),
                feature: "sku1",
                lastSubscriptionId: subscriptionId
            )
        ]
        
        let subscriptions = [
            SubscriptionInternal(
                id: subscriptionId,
                state: .active,
                createdAt: Date(),
                canceledAt: Date(),
                currentPeriodStartAt: Date(),
                currentPeriodEndAt: Date(),
                nextSubscriptionId: nil,
                pricePoint: .init(
                    ident: "",
                    services: [],
                    currencyCode: "",
                    nextTotalPrice: "",
                    nextPeriodValue: nil,
                    nextPeriodType: nil,
                    introTotalPrice: "",
                    introPeriodValue: nil,
                    introPeriodType: nil
                ),
                tags: [.trial]
            )
        ]
        
        let paidFeatures = mapper.map(features, and: subscriptions)
        
        guard case let .subscription(subscriptions) = paidFeatures.first?.paymentType else {
            XCTAssert(false)
            return
        }

        XCTAssertEqual(subscriptions.current.isTrial, true)
        XCTAssertEqual(subscriptions.current.id, subscriptionId)
    }
    
    func testCancelled() {
        let subscriptionId = UUID()
        
        let features = [
            FeatureInternal(
                quantity: 1,
                actualFrom: Date(timeIntervalSince1970: 0),
                actualTill: Date(timeIntervalSince1970: 100),
                feature: "sku1",
                lastSubscriptionId: subscriptionId
            )
        ]
        
        let subscriptions = [
            SubscriptionInternal(
                id: subscriptionId,
                state: .active,
                createdAt: Date(),
                canceledAt: Date(timeIntervalSince1970: 50),
                currentPeriodStartAt: Date(),
                currentPeriodEndAt: Date(),
                nextSubscriptionId: nil,
                pricePoint: .init(
                    ident: "",
                    services: [],
                    currencyCode: "",
                    nextTotalPrice: "",
                    nextPeriodValue: nil,
                    nextPeriodType: nil,
                    introTotalPrice: "",
                    introPeriodValue: nil,
                    introPeriodType: nil
                ),
                tags: []
            )
        ]
        
        let paidFeatures = mapper.map(features, and: subscriptions)
        
        XCTAssertEqual(paidFeatures.first?.name, "sku1")
        
        guard case let .subscription(subscriptions) = paidFeatures.first?.paymentType else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(subscriptions.current.cancellationDate, Date(timeIntervalSince1970: 50))
        XCTAssertEqual(subscriptions.current.isTrial, false)
    }

    func testSubscriptionId() {
        let subscriptionId1 = UUID()
        let subscriptionId2 = UUID()

        let features = [
            FeatureInternal(
                quantity: 1,
                actualFrom: Date(timeIntervalSince1970: 0),
                actualTill: Date(timeIntervalSince1970: 100),
                feature: "sku1",
                lastSubscriptionId: subscriptionId1
            )
        ]

        let subscriptions = [
            SubscriptionInternal(
                id: subscriptionId1,
                state: .active,
                createdAt: Date(),
                canceledAt: nil,
                currentPeriodStartAt: Date(),
                currentPeriodEndAt: Date(),
                nextSubscriptionId: subscriptionId2,
                pricePoint: .init(
                    ident: "",
                    services: [],
                    currencyCode: "",
                    nextTotalPrice: "",
                    nextPeriodValue: nil,
                    nextPeriodType: nil,
                    introTotalPrice: "",
                    introPeriodValue: nil,
                    introPeriodType: nil
                ),
                tags: []
            ),
            SubscriptionInternal(
                id: subscriptionId2,
                state: .upcoming,
                createdAt: Date(),
                canceledAt: Date(timeIntervalSince1970: 50),
                currentPeriodStartAt: Date(),
                currentPeriodEndAt: Date(),
                nextSubscriptionId: nil,
                pricePoint: .init(
                    ident: "",
                    services: [],
                    currencyCode: "",
                    nextTotalPrice: "",
                    nextPeriodValue: nil,
                    nextPeriodType: nil,
                    introTotalPrice: "",
                    introPeriodValue: nil,
                    introPeriodType: nil
                ),
                tags: []
            )
        ]

        let paidFeatures = mapper.map(features, and: subscriptions)

        XCTAssertEqual(paidFeatures.first?.name, "sku1")

        guard case let .subscription(subscriptions) = paidFeatures.first?.paymentType else {
            XCTAssert(false)
            return
        }

        XCTAssertEqual(subscriptions.current.id, subscriptionId1)
        XCTAssertEqual(subscriptions.next?.id, subscriptionId2)
    }
}
