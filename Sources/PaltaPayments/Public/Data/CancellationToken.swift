//
//  CancellationToken.swift
//  PaltaPayments
//
//  Created by Vyacheslav Beltyukov on 20/01/2023.
//

import Foundation

public struct CancellationToken: Hashable {
    let pluginId: AnyHashable
    let internalId: AnyHashable
}
