//
//  GetPricePointsPayload.swift
//  
//
//  Created by Vyacheslav Beltyukov on 15/03/2024.
//

import Foundation

struct GetPricePointsPayload: Encodable {
    let customerId: UserId
    let ident: Set<String>
}
