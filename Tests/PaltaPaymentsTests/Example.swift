//
//  File.swift
//  
//
//  Created by Vyacheslav Beltyukov on 07/03/2024.
//

import PaltaPayments

class Example {
    func doExample() {
        PaltaPurchases.instance.getPaidFeatures { result in
            try! result.get().hasActiveFeature(with: "some id")
        }
        
        PaltaPurchases.instance.getFeatures { result in
            try! result.get().contains(where: { $0.name == "some id" })
        }
        
        PaltaPurchases.instance.getSubscriptions { _ in
            
        }
    }
}
