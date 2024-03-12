//
//  Features.swift
//  
//
//  Created by Vyacheslav Beltyukov on 12/03/2024.
//

import Foundation

public struct Features: Equatable {
    private var featuresByName: [String: Set<Feature>]
    
    init(features: [Feature] = []) {
        featuresByName = Dictionary(grouping: features, by: { $0.name }).mapValues { Set($0) }
    }
    
    mutating func merge(with paidFeatures: Features) {
        paidFeatures.featuresByName.forEach {
            featuresByName[$0.key] = (featuresByName[$0.key] ?? []).union($0.value)
        }
    }
    
    func merged(with paidFeatures: Features) -> Features {
        var copy = self
        copy.merge(with: paidFeatures)
        return copy
    }
}

extension Features {
    public func hasActiveFeature(with name: String) -> Bool {
        featuresByName[name]?.contains(where: { $0.isActive }) ?? false
    }
}

extension Features {
    public var features: [Feature] {
        featuresByName.values.flatMap { $0 }
    }
    
    public var activeFeatures: [Feature] {
        features.filter { $0.isActive }
    }
    
    public subscript(_ name: String) -> [Feature] {
        featuresByName[name].map(Array.init) ?? []
    }
}
