//
//  Logger.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 09/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation

class Logger {

    static func debug(_ data: @autoclosure () throws -> CustomStringConvertible?) {
        #if DEBUG
        do {
            let d = try data()
            if let string = d?.description {
                print(string)
            } else {
                print("nil")
            }
        } catch {
            Logger.error(error)
        }
        #endif
    }


    static func error(_ error: Error) {
        print(error)
    }
}

extension String {

    init?(data: Data?) {
        guard let data = data else { return nil }
        self.init(data: data, encoding: .utf8)
    }
}
