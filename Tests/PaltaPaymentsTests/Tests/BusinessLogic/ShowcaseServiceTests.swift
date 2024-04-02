//
//  ShowcaseServiceTests.swift
//  
//
//  Created by Vyacheslav Beltyukov on 19/03/2024.
//

import Foundation
import XCTest
@testable import PaltaPayments

final class ShowcaseServiceTests: XCTestCase {
    var envMock: Environment!
    var httpMock: HTTPClientMock!
    
    var service: ShowcaseServiceImpl!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        envMock = URL(string: "https://\(UUID().uuidString).com")
        httpMock = .init()
        
        service = ShowcaseServiceImpl(environment: envMock, httpClient: httpMock)
    }
    
    func testWebPPSuccessfulFetch() {
        httpMock.result = .success(PricePointsResponse(pricePoints: []))
        let userId = UserId.uuid(UUID())
        let success = expectation(description: "Succeeded")
        
        service.getPricePoints(with: ["ident1", "ident2"], for: userId) { result in
            guard case .success = result else {
                XCTAssert(false)
                return
            }
            
            success.fulfill()
        }
        
        wait(for: [success], timeout: 0.1)
        
        guard let request = httpMock.request as? PaymentsHTTPRequest else {
            XCTAssert(false)
            return
        }
        
        guard case let .getPricePoints(env, requestUserId, idents) = request else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(env, envMock)
        XCTAssertEqual(requestUserId, userId)
        XCTAssertEqual(idents, ["ident1", "ident2"])
    }
    
    func testWebPPIntroMapping() {
        httpMock.result = .success(
            PricePointsResponse(
                pricePoints: [
                    PricePointInternal(
                        ident: "zing_premium_1m_43_27_intro_28_99_aud",
                        name: "name_name",
                        currencyCode: "USD",
                        type: .intro,
                        nextPeriodValue: nil,
                        nextPeriodType: nil,
                        nextTotalPrice: nil,
                        introPeriodValue: 1,
                        introPeriodType: "day",
                        introTotalPrice: "0.99"
                    )
                ]
            )
        )
        
        let expectedPricePoint = WebPricePoint(
            ident: "zing_premium_1m_43_27_intro_28_99_aud",
            name: "name_name",
            payment: .intro(
                .init(
                    price: 0.99,
                    period: SubscriptionPeriod(value: 1, unit: .day),
                    currencyCode: "USD"
                )
            )
        )
        
        let success = expectation(description: "Succeeded")
        
        service.getPricePoints(with: ["ident1"], for: .uuid(UUID())) { result in
            guard case let .success(pricePoints) = result else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(pricePoints.first, expectedPricePoint)
            
            success.fulfill()
        }
        
        wait(for: [success], timeout: 0.1)
    }
    
    func testWebPPIntroNextMapping() {
        httpMock.result = .success(
            PricePointsResponse(
                pricePoints: [
                    PricePointInternal(
                        ident: "zing_premium_1m_43_27_intro_28_99_aud",
                        name: "name_name_name",
                        currencyCode: "AUD",
                        type: .introNext,
                        nextPeriodValue: 2,
                        nextPeriodType: "year",
                        nextTotalPrice: "43.27",
                        introPeriodValue: 1,
                        introPeriodType: "month",
                        introTotalPrice: "28.99"
                    )
                ]
            )
        )
        
        let expectedPricePoint = WebPricePoint(
            ident: "zing_premium_1m_43_27_intro_28_99_aud",
            name: "name_name_name",
            payment: .subscription(
                .init(
                    introPrice: 28.99,
                    introPeriod: SubscriptionPeriod(value: 1, unit: .month),
                    price: 43.27,
                    period: SubscriptionPeriod(value: 2, unit: .year),
                    currencyCode: "AUD"
                )
            )
        )
        
        let success = expectation(description: "Succeeded")
        
        service.getPricePoints(with: ["ident1"], for: .uuid(UUID())) { result in
            guard case let .success(pricePoints) = result else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(pricePoints.first, expectedPricePoint)
            
            success.fulfill()
        }
        
        wait(for: [success], timeout: 0.1)
    }
    
    func testWebPPOneTimeMapping() {
        httpMock.result = .success(
            PricePointsResponse(
                pricePoints: [
                    PricePointInternal(
                        ident: "zing_premium_1m_43_27_intro_28_99_aud",
                        name: "name",
                        currencyCode: "GBP",
                        type: .lifetime,
                        nextPeriodValue: nil,
                        nextPeriodType: nil,
                        nextTotalPrice: nil,
                        introPeriodValue: nil,
                        introPeriodType: nil,
                        introTotalPrice: "6.98"
                    )
                ]
            )
        )
        
        let expectedPricePoint = WebPricePoint(
            ident: "zing_premium_1m_43_27_intro_28_99_aud",
            name: "name",
            payment: .oneTime(
                .init(price: 698 / 100, currencyCode: "GBP")
            )
        )
        
        let success = expectation(description: "Succeeded")
        
        service.getPricePoints(with: ["ident1"], for: .uuid(UUID())) { result in
            guard case let .success(pricePoints) = result else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(pricePoints.first, expectedPricePoint)
            
            success.fulfill()
        }
        
        wait(for: [success], timeout: 0.1)
    }
    
    func testWebPPFreebieMapping() {
        httpMock.result = .success(
            PricePointsResponse(
                pricePoints: [
                    PricePointInternal(
                        ident: "zing_premium_1m_43_27_intro_28_99_aud",
                        name: "freebie",
                        currencyCode: "GBP",
                        type: .freebie,
                        nextPeriodValue: nil,
                        nextPeriodType: nil,
                        nextTotalPrice: nil,
                        introPeriodValue: nil,
                        introPeriodType: nil,
                        introTotalPrice: nil
                    )
                ]
            )
        )
        
        let expectedPricePoint = WebPricePoint(
            ident: "zing_premium_1m_43_27_intro_28_99_aud",
            name: "freebie",
            payment: .freebie
        )
        
        let success = expectation(description: "Succeeded")
        
        service.getPricePoints(with: ["ident1"], for: .uuid(UUID())) { result in
            guard case let .success(pricePoints) = result else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(pricePoints.first, expectedPricePoint)
            
            success.fulfill()
        }
        
        wait(for: [success], timeout: 0.1)
    }
    
    func testWebPPFailure() {
        httpMock.result = nil
        let failed = expectation(description: "Failed")
        
        service.getPricePoints(with: ["ident1"], for: .uuid(UUID())) { result in
            guard case .failure = result else {
                XCTAssert(false)
                return
            }
            
            failed.fulfill()
        }
        
        wait(for: [failed], timeout: 0.1)
    }
    
    func testProductsSuccessfulFetch() {
        httpMock.result = .success(PricePointsResponse(pricePoints: []))
        let userId = UserId.uuid(UUID())
        let success = expectation(description: "Succeeded")
        
        service.getProducts(with: ["ident1", "ident2"], for: userId) { result in
            guard case .success = result else {
                XCTAssert(false)
                return
            }
            
            success.fulfill()
        }
        
        wait(for: [success], timeout: 0.1)
        
        guard let request = httpMock.request as? PaymentsHTTPRequest else {
            XCTAssert(false)
            return
        }
        
        guard case let .getPricePoints(env, requestUserId, idents) = request else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(env, envMock)
        XCTAssertEqual(requestUserId, userId)
        XCTAssertEqual(idents, ["ident1", "ident2"])
    }
    
    func testProductsIntroMapping() {
        httpMock.result = .success(
            PricePointsResponse(
                pricePoints: [
                    PricePointInternal(
                        ident: "zing_premium_1m_43_27_intro_28_99_aud",
                        name: "name_name",
                        currencyCode: "USD",
                        type: .intro,
                        nextPeriodValue: nil,
                        nextPeriodType: nil,
                        nextTotalPrice: nil,
                        introPeriodValue: 1,
                        introPeriodType: "day",
                        introTotalPrice: "0.99"
                    )
                ]
            )
        )
        
        let expectedPricePoint = WebPricePoint(
            ident: "zing_premium_1m_43_27_intro_28_99_aud",
            name: "name_name",
            payment: .intro(
                .init(
                    price: 0.99,
                    period: SubscriptionPeriod(value: 1, unit: .day),
                    currencyCode: "USD"
                )
            )
        )
        
        let success = expectation(description: "Succeeded")
        
        service.getPricePoints(with: ["ident1"], for: .uuid(UUID())) { result in
            guard case let .success(pricePoints) = result else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(pricePoints.first, expectedPricePoint)
            
            success.fulfill()
        }
        
        wait(for: [success], timeout: 0.1)
    }
    
    func testProductsIntroNextMapping() {
        httpMock.result = .success(
            PricePointsResponse(
                pricePoints: [
                    PricePointInternal(
                        ident: "zing_premium_1m_43_27_intro_28_99_aud",
                        name: "name_name_name",
                        currencyCode: "AUD",
                        type: .introNext,
                        nextPeriodValue: 2,
                        nextPeriodType: "year",
                        nextTotalPrice: "43.27",
                        introPeriodValue: 1,
                        introPeriodType: "month",
                        introTotalPrice: "28.99"
                    )
                ]
            )
        )
        
        let expectedIntroDiscount = ProductDiscount(
            offerIdentifier: nil,
            currencyCode: "AUD",
            price: Decimal(string: "28.99")!,
            numberOfPeriods: 1,
            subscriptionPeriod: SubscriptionPeriod(value: 1, unit: .month),
            localizedPriceString: "",
            originalEntity: ""
        )
        
        let success = expectation(description: "Succeeded")
        
        service.getProducts(with: ["ident1"], for: .uuid(UUID())) { result in
            guard case let .success(products) = result else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(products.first?.productType, .autoRenewableSubscription)
            XCTAssertEqual(products.first?.productIdentifier, "zing_premium_1m_43_27_intro_28_99_aud")
            XCTAssertEqual(products.first?.localizedDescription, "")
            XCTAssertEqual(products.first?.localizedTitle, "name_name_name")
            XCTAssertEqual(products.first?.currencyCode, "AUD")
            XCTAssertEqual(products.first?.price, Decimal(string: "43.27"))
            XCTAssertEqual(products.first?.subscriptionPeriod, SubscriptionPeriod(value: 2, unit: .year))
            XCTAssertEqual(products.first?.introductoryDiscount, expectedIntroDiscount)
            XCTAssertEqual(products.first?.discounts, [])
            XCTAssert(products.first?.originalEntity is WebPricePoint)
            
            success.fulfill()
        }
        
        wait(for: [success], timeout: 0.1)
    }
    
    func testProductsOneTimeMapping() {
        httpMock.result = .success(
            PricePointsResponse(
                pricePoints: [
                    PricePointInternal(
                        ident: "zing_premium_1m_43_27_intro_28_99_aud",
                        name: "name",
                        currencyCode: "GBP",
                        type: .lifetime,
                        nextPeriodValue: nil,
                        nextPeriodType: nil,
                        nextTotalPrice: nil,
                        introPeriodValue: nil,
                        introPeriodType: nil,
                        introTotalPrice: "6.98"
                    )
                ]
            )
        )
        
        let success = expectation(description: "Succeeded")
        
        service.getProducts(with: ["ident1"], for: .uuid(UUID())) { result in
            guard case let .success(products) = result else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(products.first?.productType, .nonConsumable)
            XCTAssertEqual(products.first?.productIdentifier, "zing_premium_1m_43_27_intro_28_99_aud")
            XCTAssertEqual(products.first?.localizedDescription, "")
            XCTAssertEqual(products.first?.localizedTitle, "name")
            XCTAssertEqual(products.first?.currencyCode, "GBP")
            XCTAssertEqual(products.first?.price, Decimal(string: "6.98"))
            XCTAssertEqual(products.first?.subscriptionPeriod, nil)
            XCTAssertEqual(products.first?.introductoryDiscount, nil)
            XCTAssertEqual(products.first?.discounts, [])
            XCTAssert(products.first?.originalEntity is WebPricePoint)
            
            success.fulfill()
        }
        
        wait(for: [success], timeout: 0.1)
    }
    
    func testProductsFreebieMapping() {
        httpMock.result = .success(
            PricePointsResponse(
                pricePoints: [
                    PricePointInternal(
                        ident: "zing_premium_1m_43_27_intro_28_99_aud",
                        name: "freebie",
                        currencyCode: "GBP",
                        type: .freebie,
                        nextPeriodValue: nil,
                        nextPeriodType: nil,
                        nextTotalPrice: nil,
                        introPeriodValue: nil,
                        introPeriodType: nil,
                        introTotalPrice: nil
                    )
                ]
            )
        )
        
        let success = expectation(description: "Succeeded")
        
        service.getProducts(with: ["ident1"], for: .uuid(UUID())) { result in
            guard case let .success(products) = result else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(products.first?.productType, .nonConsumable)
            XCTAssertEqual(products.first?.productIdentifier, "zing_premium_1m_43_27_intro_28_99_aud")
            XCTAssertEqual(products.first?.localizedDescription, "")
            XCTAssertEqual(products.first?.localizedTitle, "freebie")
            XCTAssertEqual(products.first?.currencyCode, "")
            XCTAssertEqual(products.first?.price, 0)
            XCTAssertEqual(products.first?.subscriptionPeriod, nil)
            XCTAssertEqual(products.first?.introductoryDiscount, nil)
            XCTAssertEqual(products.first?.discounts, [])
            XCTAssert(products.first?.originalEntity is WebPricePoint)
            
            success.fulfill()
        }
        
        wait(for: [success], timeout: 0.1)
    }
    
    func testProductsFailure() {
        httpMock.result = nil
        let failed = expectation(description: "Failed")
        
        service.getProducts(with: ["ident1"], for: .uuid(UUID())) { result in
            guard case .failure = result else {
                XCTAssert(false)
                return
            }
            
            failed.fulfill()
        }
        
        wait(for: [failed], timeout: 0.1)
    }
}
