//
//  PricePointsResponse.swift
//  
//
//  Created by Vyacheslav Beltyukov on 14/03/2024.
//

import Foundation

struct PricePointsResponse: Decodable {
    let pricePoints: [PricePointInternal]
}
