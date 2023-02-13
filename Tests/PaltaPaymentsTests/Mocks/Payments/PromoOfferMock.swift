//
//  PromoOfferMock.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 12/05/2022.
//

import Foundation
import PaltaPayments

struct PromoOfferMock: PromoOffer {
    var productDiscount: ProductDiscount = .mock()
}
