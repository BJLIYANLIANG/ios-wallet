//
//  CompareUtils.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 23/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation

func containsNilField<T>(object: T) -> Bool {
    return Mirror(reflecting: object).children.contains(where: {
        if case Optional<Any>.some(_) = $0.value {
            return false
        } else {
            return true
        }
    })
}

func containsNotNilField<T>(object: T) -> Bool {
    return Mirror(reflecting: object).children.contains(where: {
        if case Optional<Any>.some(_) = $0.value {
            return true
        } else {
            return false
        }
    })
}
