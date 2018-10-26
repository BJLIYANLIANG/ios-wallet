//
//  Formats.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 26/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation

private let trasactionDateTimeFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EE dd/MM/yy HH:mm:ss"
    return dateFormatter
}()

extension Date {
    var trasactionDateTime: String {
        return trasactionDateTimeFormatter.string(from: self)
    }
}
