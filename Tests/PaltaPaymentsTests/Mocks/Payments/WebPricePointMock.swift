//
//  WebPricePointMock.swift
//  
//
//  Created by Vyacheslav Beltyukov on 19/03/2024.
//

@testable import PaltaPayments

extension WebPricePoint {
    static func mock(ident: String = "mock-ident") -> WebPricePoint {
        WebPricePoint(
            ident: ident,
            name: "mock name",
            payment: .freebie
        )
    }
}
