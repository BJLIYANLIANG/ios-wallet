//
//  UIExtensions.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 08/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit
import JetLib


public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension ActionCommand {

    static func pushScreen(_ from: UIViewController, sbName: String, controllerId: String) -> ActionCommand {
        return ActionCommand(from) {
            let storyboard = UIStoryboard(name: sbName, bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: controllerId)
            $0.navigationController?.pushViewController(controller, animated: true)
        }
    }

    static func pushScreen<T: UIViewController>(_ from: UIViewController, sbName: String, controllerId: String, configure: @escaping (T) -> Void) -> ActionCommand {
        return ActionCommand(from) {
            let storyboard = UIStoryboard(name: sbName, bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: controllerId) as! T
            configure(controller)
            $0.navigationController?.pushViewController(controller, animated: true)
        }
    }

    static func pushScreen(_ from: UIViewController, create: @escaping () -> UIViewController) -> ActionCommand {
        return ActionCommand(from) {
            $0.navigationController?.pushViewController(create(), animated: true)
        }
    }
}
