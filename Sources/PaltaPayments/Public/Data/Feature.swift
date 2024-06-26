//
//  Feature.swift
//  
//
//  Created by Vyacheslav Beltyukov on 07/03/2024.
//

import Foundation

public struct Feature: Hashable {
    public let name: String
    
    public let startDate: Date
    public let endDate: Date?
}

extension Feature {
    public var isLifetime: Bool {
        endDate == nil
    }
    
    public var isActive: Bool {
        let now = Date()
        
        return now > startDate && endDate.map { $0 > now } ?? true
    }
}

