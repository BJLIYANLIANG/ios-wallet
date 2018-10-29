//
//  UnitConversionTests.swift
//  EthereumWalletTests
//
//  Created by Vladimir Benkevich on 26/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import XCTest
@testable import EthereumWallet

class UnitConversionTests: XCTestCase {

    func testWeiConversion() {
        XCTAssertEqual("11060000000000000000".ether?.decimal, Decimal(11.06))
        XCTAssertEqual("0x100000000000000000001".ether?.wei, "0x100000000000000000001")
    }
}
