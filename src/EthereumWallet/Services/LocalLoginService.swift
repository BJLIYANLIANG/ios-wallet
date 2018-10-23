//
//  LocalLoginService.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 18/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import JetLib
import LocalAuthentication

class LocalLoginService {

    enum BiometricType {
        case none
        case faceId
        case touchId
    }

    enum Errors: Error {
        case pincodeAlredySet
        case pincodeNotSet
        case brokenData
        case keychainError(status: OSStatus)
    }

    private let queue = DispatchQueue.global(qos: .userInteractive)
    private let context = LAContext()
    private let serviceName = "devpool"

    init() {
        context.localizedCancelTitle = "<TODO> Enter Pincode"
    }

    var isBiometricLoginPreffered: Bool {
        get { return UserDefaults.standard.bool(forKey: LocalStorageKeys.useBiomericLogin.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: LocalStorageKeys.useBiomericLogin.rawValue)}
    }

    var isAvailableBiometric: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    var isPincodeInited: Bool {
        get { return UserDefaults.standard.bool(forKey: LocalStorageKeys.pincodeInited.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: LocalStorageKeys.pincodeInited.rawValue) }
    }

    var biometricType: BiometricType {
        if !isAvailableBiometric {
            return .none
        }

        if #available(iOS 11.0, *) {
            if context.biometryType == .faceID {
                return .faceId
            }
        }

        return .touchId
    }

    func biometricLogin() -> Task<Bool> {
        let taskSource = Task<Bool>.Source()
        let reason = "<TODO> ..."

        context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
            if let error = $1 {
                try? taskSource.error(error)
            } else {
                try? taskSource.complete($0)
            }
        }

        return taskSource.task
    }

    func pincodeLogin(pincode: String) -> Bool {
        return queue.sync {
            do {
                return try readPincodeFromKeychain() == pincode
            } catch {
                return false
            }
        }
    }

    func setPinCode(pincode: String) throws {
        try queue.sync {
            if (try? readPincodeImpl()) != nil {
                try removePinImpl()
            }

            try setPincodeImpl(pincode)
            isPincodeInited = true
        }
    }

    func clearPincode() throws {
        try queue.sync {
            isPincodeInited = false
            try removePinImpl()
        }
    }

    func readPincodeFromKeychain() throws -> String? {
        return try queue.sync {
            return try readPincodeImpl()
        }
    }

    fileprivate func newPincodeQuery() -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecAttrAccessGroup as String] = nil
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = serviceName as AnyObject

        return query
    }

    fileprivate func setPincodeImpl(_ pincode: String) throws {
        var query = newPincodeQuery()
        query[kSecValueData as String] = pincode.data(using: .utf8) as AnyObject?

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != noErr {
            throw Errors.keychainError(status: status)
        }
    }

    fileprivate func removePinImpl() throws {
        let query = newPincodeQuery()
        let status = SecItemDelete(query as CFDictionary)

        guard status == noErr || status == errSecItemNotFound else {
            throw Errors.keychainError(status: status)
        }
    }

    fileprivate func readPincodeImpl() throws -> String? {
        var result: AnyObject?

        var query = newPincodeQuery()
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        guard status != errSecItemNotFound else {
            throw Errors.pincodeNotSet
        }

        guard status == noErr else {
            throw Errors.keychainError(status: status)
        }

        guard let item = result as? [String : AnyObject],
            let data = item[kSecValueData as String] as? Data,
            let pincode = String(data: data, encoding: .utf8)
            else {
                throw Errors.brokenData
        }

        return pincode
    }
}
