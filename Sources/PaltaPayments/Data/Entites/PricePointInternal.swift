//
//  PricePointInternal.swift
//  
//
//  Created by Vyacheslav Beltyukov on 14/03/2024.
//

import Foundation

struct PricePointInternal: Decodable, Equatable {
    enum PPType: String, Decodable {
        case intro
        case introNext = "intro_next"
        case lifetime
        case freebie
    }
    
    let ident: String
    let name: String
    let currencyCode: String
    let type: PPType
    let nextPeriodValue: Int?
    let nextPeriodType: String?
    let nextTotalPrice: String?
    let introPeriodValue: Int?
    let introPeriodType: String?
    let introTotalPrice: String?
}
