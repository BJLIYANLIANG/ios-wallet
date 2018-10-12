//
//  Network.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 09/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation

struct Network {

    static let infuraApiKey = "74d6c4da5ad64f609cf2eccd62a5d2c5"

    // TODO: get from plist
    static let all: [Network] = [
        Network(networkName: "rinkeby",
                infuraUrl: URL(string: "https://rinkeby.infura.io/v3")!,
                eherScanUrl: URL(string: "https://rinkeby.etherscan.io/api")!),
        Network(networkName: "ropsten",
                infuraUrl: URL(string: "https://ropsten.infura.io/v3")!,
                eherScanUrl: URL(string: "https://ropsten.etherscan.io/api")!),
        Network(networkName: "kovan",
                infuraUrl: URL(string: "https://kovan.infura.io/v3")!,
                eherScanUrl: URL(string: "https://kovan.etherscan.io/api")!),
        Network(networkName: "mainnet",
                infuraUrl: URL(string: "https://mainnet.infura.io/v3")!,
                eherScanUrl: URL(string: "https://???.etherscan.io/api")!),
    ]

    // TODO: store last selection
    static var current: Network = Network.all.first!

    let networkName: String

    fileprivate let infuraUrl: URL
    fileprivate let eherScanUrl: URL

    var jsonRpc: URL {
        return Network.current.infuraUrl.appendingPathComponent(Network.infuraApiKey)
    }

    var eherScan: URL {
        return Network.current.eherScanUrl
    }
}
