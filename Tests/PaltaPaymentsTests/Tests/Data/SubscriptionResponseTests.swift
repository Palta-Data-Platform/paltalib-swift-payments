//
//  SubscriptionResponseTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
import XCTest
import PaltaCore
@testable import PaltaPayments

final class SubscriptionResponseTests: XCTestCase {
    func testDecode() throws {
        let data = """
{
  "status": "success",
  "subscriptions": [
    {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "state": "new",
      "createdAt": "2022-04-20T08:22:05.226000+00:00",
      "canceledAt": "2022-05-20T08:22:05.226000+00:00",
      "currentPeriodStartAt": "2022-06-20T08:22:05.226000+00:00",
      "currentPeriodEndAt": "2022-07-20T08:22:05.226000+00:00",
      "tags": [
        "trial",
        "unknown-tag"
      ],
      "pricePoint": {
          "ident": "string",
          "nextTotalPrice": "string",
          "introTotalPrice": "string",
          "currencyCode": "string",
          "services": [
              {
                  "featureIdent": "string",
                  "featureType": "timebased",
                  "quantity": 0
              }
          ]
      }
    },
    {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "state": "active",
      "createdAt": "2022-04-20T08:22:05.226000+00:00",
      "canceledAt": "2022-05-20T08:22:05.226000+00:00",
      "currentPeriodStartAt": "2022-06-20T08:22:05.226000+00:00",
      "currentPeriodEndAt": "2022-07-20T08:22:05.226000+00:00",
      "tags": [],
      "pricePoint": {
          "ident": "string",
          "nextTotalPrice": "string",
          "introTotalPrice": "string",
          "currencyCode": "string",
          "services": [
              {
                  "featureIdent": "string",
                  "featureType": "timebased",
                  "quantity": 0
              }
          ]
      },
      "nextSubscriptionId": "3fa85f64-5717-4562-b3fc-2c963f66ab8a"
    },
    {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "state": "canceled",
      "createdAt": "2022-04-20T08:22:05.226000+00:00",
      "canceledAt": "2022-05-20T08:22:05.226000+00:00",
      "currentPeriodStartAt": "2022-06-20T08:22:05.226000+00:00",
      "currentPeriodEndAt": "2022-07-20T08:22:05.226000+00:00",
      "tags": [],
      "pricePoint": {
          "ident": "string",
          "nextTotalPrice": "string",
          "introTotalPrice": "string",
          "currencyCode": "string",
          "services": [
              {
                  "featureIdent": "string",
                  "featureType": "timebased",
                  "quantity": 0
              }
          ]
      }
    },
    {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "state": "is_upcoming",
      "createdAt": "2022-04-20T08:22:05.226000+00:00",
      "canceledAt": "2022-05-20T08:22:05.226000+00:00",
      "currentPeriodStartAt": "2022-06-20T08:22:05.226000+00:00",
      "currentPeriodEndAt": "2022-07-20T08:22:05.226000+00:00",
      "tags": [],
      "pricePoint": {
          "ident": "string",
          "nextTotalPrice": "string",
          "introTotalPrice": "string",
          "currencyCode": "string",
          "services": [
              {
                  "featureIdent": "string",
                  "featureType": "timebased",
                  "quantity": 0
              }
          ]
      }
    }
  ]
}
""".data(using: .utf8)!
        
        let response = try JSONDecoder.default.decode(SubscriptionResponse.self, from: data)
        
        XCTAssertEqual(response.subscriptions.first?.tags.first, .trial)
        
        XCTAssert(response.subscriptions.contains(where: { $0.state == .new }))
        XCTAssert(response.subscriptions.contains(where: { $0.state == .cancelled }))
        XCTAssert(response.subscriptions.contains(where: { $0.state == .active }))
        XCTAssert(response.subscriptions.contains(where: { $0.state == .upcoming }))
        
        XCTAssertEqual(
            response.subscriptions.first?.createdAt,
            Date(timeIntervalSince1970: 1650442925.226)
        )
        XCTAssertEqual(
            response.subscriptions.first?.canceledAt,
            Date(timeIntervalSince1970: 1653034925.226)
        )
        XCTAssertEqual(
            response.subscriptions.first?.currentPeriodStartAt,
            Date(timeIntervalSince1970: 1655713325.226)
        )
        XCTAssertEqual(
            response.subscriptions.first?.currentPeriodEndAt,
            Date(timeIntervalSince1970: 1658305325.226)
        )
        XCTAssertNil(response.subscriptions.first?.nextSubscriptionId)
        
        XCTAssertEqual(
            response.subscriptions[1].nextSubscriptionId,
            UUID(uuidString: "3fa85f64-5717-4562-b3fc-2c963f66ab8a")
        )
    }
}
