//
//  UtilsExtensions.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 08/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib

extension HttpClient {

    var mock: HttpClient.URLSessionMockDecorator {
        if let mock = self.urlSession as? HttpClient.URLSessionMockDecorator {
            return mock
        }

        let mock = URLSessionMockDecorator(origin: self.urlSession)
        self.urlSession = mock
        return mock
    }
}

extension HttpClient.URLSessionMockDecorator {

    func setJsonResult<T: Codable>(_ data: T, for url: URL, lifetime: Lifetime = .thisSession) {
        self.setResult(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil),
                       data: try! HttpClient.Json.defaultEncoder.encode(data),
                       error: nil,
                       for: url,
                       lifetime: lifetime)
    }
}

extension Task {

    static func cancelled() -> Task {
        let src = Task.Source()
        try! src.cancel()
        return src.task
    }
}
