//
//  JsonRPC.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 10/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation

class JsonRPC {

    static private (set) var lastRequestNumber: Int64 = 0

    struct Request: Codable {

        init(_ method: String, content: [String], version: String = "2.0") {
            self.method = method
            self.content = content
            self.version = version
            self.requestId = OSAtomicIncrement64(&JsonRPC.lastRequestNumber)
        }

        let version: String
        let method: String
        let content: [String]
        let requestId: Int64

        enum CodingKeys: String, CodingKey {
            case version = "jsonrpc"
            case method = "method"
            case content = "params"
            case requestId = "id"
        }
    }

    struct Response<T: Codable>: Codable {
        let version: String
        let requestId: Int64
        let result: T

        enum CodingKeys: String, CodingKey {
            case version = "jsonrpc"
            case result = "result"
            case requestId = "id"
        }
    }
}
