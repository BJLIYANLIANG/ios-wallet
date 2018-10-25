//
//  AccountDetailsController.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 25/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit
import JetLib

class AccountDetailsController: UIViewController {

    @IBOutlet weak var qrcodeBackView: UIView!
    @IBOutlet weak var qrcodeView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyAddressButton: UIButton!

    var account: Account! {
        didSet {
            loadViewIfNeeded()
            self.title = account?.address // TODO
            addressLabel.text = account.address
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        copyAddressButton.command = ActionCommand(self) {
            UIPasteboard.general.string = $0.account.address
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        qrcodeView.image = generateQrCodeImage(code: account.address, color: UIColor.black, size: qrcodeView.bounds.size)
    }

    func generateQrCodeImage(code: String, color: UIColor, size: CGSize) -> UIImage? {
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(code.data(using: .utf8), forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")

        guard let blackWhiteImage = filter?.outputImage else {
            return nil
        }

        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setValue(blackWhiteImage, forKey: "inputImage")
        colorFilter?.setValue(CIColor(color: UIColor.clear), forKey: "inputColor1") // Background
        colorFilter?.setValue(CIColor(color: color), forKey: "inputColor0") // Foreground

        guard let cloredImage = colorFilter?.outputImage  else {
            return nil
        }

        let imageSize = cloredImage.extent.size
        let transform = CGAffineTransform(scaleX: size.width / imageSize.width,
                                          y:  size.height / imageSize.height)

        return UIImage(ciImage: cloredImage.transformed(by: transform))
    }
}
