//
//  QRCodeScaner.swift
//  EthereumWallet
//
//  Created by Vladimir Benkevich on 25/10/2018.
//  Copyright © 2018 devpool. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol QRCoderDelegate: class {

    func detected(_ scaner: QRCodeScanerController, qrCode: String)
}

class QRCodeScanerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    enum Errors: Error {
        case noCameraDetected
    }

    weak var delegate: QRCoderDelegate?

    var recognizedCode: String? {
        didSet {
            guard recognizedCode != oldValue else {
                return
            }

            updateDecorationVisibility()

            if let code = recognizedCode, recognizedCode != oldValue {
                delegate?.detected(self, qrCode: code)
            }
        }
    }

    fileprivate var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    fileprivate var captureSession: AVCaptureSession!
    fileprivate var initializeError: Error?

    fileprivate var isLoading: Bool = false {
        didSet {
            updateDecorationVisibility()
        }
    }

    fileprivate var qrCodeDecaratorView: DimView! {
        didSet {
            if let dimView = qrCodeDecaratorView {
                dimView.isHidden = recognizedCode == nil
                view.addSubview(dimView)
            }
            oldValue?.removeFromSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "<TODO> scan account address"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))

        do {
            captureSession = try createCameraSession()
            setVideoOutput(container: view, session: captureSession)
        } catch {
            initializeError = error
            return
        }

        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession?.startRunning()
    }

    func updateDecorationVisibility() {
        qrCodeDecaratorView?.isVisible = isLoading || recognizedCode != nil
        qrCodeDecaratorView.skipClip = isLoading
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession?.stopRunning()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        qrCodeDecaratorView?.frame = view.bounds
    }

    func setupLayout() {
        qrCodeDecaratorView = DimView()
        qrCodeDecaratorView.color = UIColor.black.withAlphaComponent(0.66)
    }

    func setVideoOutput(container: UIView, session: AVCaptureSession) {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        container.layer.addSublayer(videoPreviewLayer)
    }

    func createCameraSession() throws -> AVCaptureSession {
        guard let device = getCaptureDevice() else {
            throw Errors.noCameraDetected
        }

        let input = try AVCaptureDeviceInput(device: device)
        let captureMetadataOutput = AVCaptureMetadataOutput()
        let captureSession = AVCaptureSession()
        captureSession.addInput(input)
        captureSession.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

        return captureSession
    }

    func getCaptureDevice() -> AVCaptureDevice? {
        return AVCaptureDevice.default(for: .video)
    }

    @objc func handleCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        guard let recognizedObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, recognizedObject.type == .qr else {
            recognizedCode = nil
            return
        }

        let transformed = videoPreviewLayer.transformedMetadataObject(for: recognizedObject)!
        qrCodeDecaratorView!.clipRect = transformed.bounds
        recognizedCode = recognizedObject.stringValue
    }


    class DimView: UIView {

        var color: UIColor? {
            didSet {
                setNeedsDisplay()
            }
        }

        var clipRect: CGRect? {
            didSet {
                if !skipClip {
                    setNeedsDisplay()
                }
            }
        }

        var skipClip: Bool = false {
            didSet {
                setNeedsDisplay()
            }
        }

        override func draw(_ rect: CGRect) {
            guard let context = UIGraphicsGetCurrentContext() else {
                return
            }

            if let color = color?.cgColor {
                context.setFillColor(color)
                context.fill(rect)
            }

            if let clipRect = clipRect, !skipClip {
                context.clear(clipRect)
            }
        }
    }
}
