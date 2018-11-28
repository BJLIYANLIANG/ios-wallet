//
//  ABIFunctionEncoding.swift
//  EthereumWalletTests
//
//  Created by Vladimir Benkevich on 28/11/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import XCTest
@testable import EthereumWallet

class ABIFunctionEncoding: XCTestCase {

    let bar = Function(name: "bar", input: [.uint8(255), .string("three")])
    let baz = Function(name: "baz", input: [.uint32(69), .bool(true)])

    func testBuildSignature() {
        XCTAssertEqual(baz.signature, "baz(uint32,bool)")
        XCTAssertEqual(bar.signature, "bar(uint8,string)")
    }

    func testSignatureEncoding() {
        XCTAssertEqual(bar.encodedSignature.hex, "7abdc0f3")
        XCTAssertEqual(baz.encodedSignature.hex, "cdcd77c0")
    }

    func testFunctionSelectorEncoding() {
        XCTAssertEqual(baz.encodedSelector.hex, "cdcd77c000000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001")

        XCTAssertEqual(bar.encodedSelector.hex, "7abdc0f300000000000000000000000000000000000000000000000000000000000000ff00000000000000000000000000000000000000000000000000000000000000057468726565000000000000000000000000000000000000000000000000000000")
    }
}
