//
//  FeaturesResponse.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation

struct FeaturesResponse: Decodable {
    let features: [FeatureInternal]
}
