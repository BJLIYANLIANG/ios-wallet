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
    static let etherscanApiKey = "XFZIBYHKYPY7FRIZ6FZRC6EZCF9ESNX856"

    // TODO: get from plist
    static let all: [Network] = [
        Network(networkName: "rinkeby",
                infuraUrl: URL(string: "https://rinkeby.infura.io/v3")!,
                eherscanUrl: URL(string: "https://rinkeby.etherscan.io/api")!,
                chainId: 4),
        Network(networkName: "ropsten",
                infuraUrl: URL(string: "https://ropsten.infura.io/v3")!,
                eherscanUrl: URL(string: "https://ropsten.etherscan.io/api")!,
                chainId: 3),
        Network(networkName: "kovan",
                infuraUrl: URL(string: "https://kovan.infura.io/v3")!,
                eherscanUrl: URL(string: "https://kovan.etherscan.io/api")!,
                chainId: 42),
        Network(networkName: "mainnet",
                infuraUrl: URL(string: "https://mainnet.infura.io/v3")!,
                eherscanUrl: URL(string: "https://???.etherscan.io/api")!,
                chainId: 1),
    ]

    // TODO: store last selection
    static var current: Network = Network.all.first!

    let networkName: String

    fileprivate let infuraUrl: URL
    fileprivate let eherscanUrl: URL
    let chainId: Int64

    var jsonRpc: URL {
        return Network.current.infuraUrl.appendingPathComponent(Network.infuraApiKey)
    }

    var eherscan: URL {
        return Network.current.eherscanUrl
    }

    /*
     0: Olympic, Ethereum public pre-release testnet
     1: Frontier, Homestead, Metropolis, the Ethereum public main network
     1: Classic, the (un)forked public Ethereum Classic main network, chain ID 61
     1: Expanse, an alternative Ethereum implementation, chain ID 2
     2: Morden, the public Ethereum testnet, now Ethereum Classic testnet
     3: Ropsten, the public cross-client Ethereum testnet
     4: Rinkeby, the public Geth PoA testnet
     8: Ubiq, the public Gubiq main network with flux difficulty chain ID 8
     42: Kovan, the public Parity PoA testnet
     77: Sokol, the public POA Network testnet
     99: Core, the public POA Network main network
     7762959: Musicoin, the music blockchain
     61717561: Aquachain, ASIC resistant chain
     [Other]: Could indicate that your connected to a local development test network
     */
}
