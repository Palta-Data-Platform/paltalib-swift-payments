//
//  NumberFormatter+Currency.swift
//  
//
//  Created by Vyacheslav Beltyukov on 02/04/2024.
//

import Foundation

extension NumberFormatter {
    private static var formatters: [String: NumberFormatter] = [:]
    
    static func formatter(for currency: String) -> NumberFormatter {
        if let cached = formatters[currency] {
            return cached
        }
        
        let formatter = NumberFormatter()
        formatter.currencyCode = currency
        formatter.numberStyle = .currency
        formatters[currency] = formatter
        
        return formatter
    }
}
