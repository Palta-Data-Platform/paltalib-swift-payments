//
//  PricePointsResponseTest.swift
//  
//
//  Created by Vyacheslav Beltyukov on 14/03/2024.
//

import Foundation
import XCTest
import PaltaCore
@testable import PaltaPayments

final class PricePointsResponseTest: XCTestCase {
    func testDecodeAllFields() throws {
        let data = """
{
  "status": "success",
  "pricePoints": [
    {
      "storeType": 1,
      "ident": "ident1",
      "name": "string",
      "priority": 0,
      "currencyCode": "AUD",
      "parameters": {},
      "type": "intro",
      "nextBasePrice": "string",
      "nextPeriodValue": 100,
      "nextPeriodType": "second",
      "introBasePrice": "20",
      "introPeriodValue": 10,
      "introPeriodType": "minute",
      "nextTotalPrice": "25",
      "introTotalPrice": "30",
      "productSku": "string",
      "introDiscountPrice": "string",
      "introDiscountPercentage": 0,
      "nextDiscountPrice": "string",
      "nextDiscountPercentage": 0
    }
  ],
  "products": {
    "additionalProp1": {
      "sku": "string",
      "features": [
        {
          "ident": "string",
          "quantity": 0,
          "type": "timebased"
        }
      ]
    },
    "additionalProp2": {
      "sku": "string",
      "features": [
        {
          "ident": "string",
          "quantity": 0,
          "type": "timebased"
        }
      ]
    },
    "additionalProp3": {
      "sku": "string",
      "features": [
        {
          "ident": "string",
          "quantity": 0,
          "type": "timebased"
        }
      ]
    }
  }
}
""".data(using: .utf8)!
        
        let response = try JSONDecoder.default.decode(PricePointsResponse.self, from: data)
        
        XCTAssertEqual(response.pricePoints.first?.ident, "ident1")
        
        XCTAssertEqual(
            response.pricePoints.first?.nextTotalPrice,
            "25"
        )
        
        XCTAssertEqual(
            response.pricePoints.first?.introTotalPrice,
            "30"
        )
        
        XCTAssertEqual(
            response.pricePoints.first?.nextPeriodType,
            "second"
        )
        
        XCTAssertEqual(
            response.pricePoints.first?.nextPeriodType,
            "second"
        )
        
        XCTAssertEqual(
            response.pricePoints.first?.nextPeriodValue,
            100
        )
        
        XCTAssertEqual(
            response.pricePoints.first?.introPeriodValue,
            10
        )
        
        XCTAssertEqual(
            response.pricePoints.first?.currencyCode,
            "AUD"
        )
    }
}
