//
//  ScanVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 08/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

protocol ScanVMDelegate: class {
    func codeFound()
    func handleError(error: String)
    func torchWasToggled(torchOn: Bool)
    func billionCodeDidFound()
    func scanWrongSource(with failure: String)
    func resetScan()
    func cameraAccessDenied()
}

protocol PickVMDelegate: class {
    func cropDidEnd()
}

class ScanVM: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    typealias LocalizedStrings = Strings.Scan
    var torchOn: Bool {
        didSet {
            delegate?.torchWasToggled(torchOn: torchOn)
        }
    }
    weak var delegate: ScanVMDelegate?
    weak var pickDelegate: PickVMDelegate?
    weak var accountProvider: AccountManager!
    var qrResolver: QrResolver!
    var photos: [UIImage] = []
    var croppedPhotos: [UIImage] = [] {
        didSet {
            if croppedPhotos.count > 0 {
                pickDelegate?.cropDidEnd()
            }
        }
    }
    var pickedImage: UIImage? {
        didSet {
            if let image = pickedImage {
                performQRCodeDetection(image: CIImage(image: image)!, success: { (detectedString) in
                    resolveInputFromGallery(sourceString: detectedString)
                }) { (errorString) in
                    delegate?.handleError(error: errorString)
                }
            }
        }
    }

    let captureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.metadata, position: .back)
    var captureSession = AVCaptureSession()
    var videoPreviewLayer = AVCaptureVideoPreviewLayer()
    let captureMetadataOutput = AVCaptureMetadataOutput()
    var rectOfInterest = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    
    init(provider: ScannerDataProvider, accountProvider: AccountManager, qrResolver: QrResolver) {

        self.torchOn = false
        self.accountProvider = accountProvider
        self.qrResolver = qrResolver
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        clearSessionInputsOutputs()
        self.captureSession.stopRunning()
        self.videoPreviewLayer.removeFromSuperlayer()
    }
    
    func clearSessionInputsOutputs() {
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
        for output in captureSession.outputs {
            captureSession.removeOutput(output)
        }
    }
    
    func scanQrCode(view: UIView, rectOfInterest: CGRect) {
        
        addObserver()
        self.rectOfInterest = rectOfInterest
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession.sessionPreset = .photo
            clearSessionInputsOutputs()
            captureSession.addInput(input)
            videoPreviewLayer.session = nil
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer.frame = view.layer.bounds
            view.layer.insertSublayer(videoPreviewLayer, at: 0)
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.8, execute: {
                self.captureSession.startRunning()
            })
        } catch {
            delegate?.cameraAccessDenied()
            return
        }
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(avCaptureInputPortFormatDescriptionDidChangeNotification), name: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
    }
    
    @objc func avCaptureInputPortFormatDescriptionDidChangeNotification(notification: NSNotification) {
        let roi = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: rectOfInterest)
        captureMetadataOutput.rectOfInterest = roi
    }
    
    // MARK: Capture delegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        delegate?.resetScan()
        if metadataObjects.count == 0 {
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            if let address = metadataObj.stringValue {
                resolveInputFromCamera(sourceString: address)
            }
        }
    }
    
    func toggleFlash() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                torchOn = !device.isTorchActive
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
                device.torchMode = torchOn ? .on : .off
                device.unlockForConfiguration()
            } catch {
                Logger.error("\(error)")
            }
        }
    }

    // MARK: Picker Preparing
    func getPhotos() {
        let photoLibrary = PhotoLibrary()
        DispatchQueue.global().async {
            self.photos = photoLibrary.getPhotos(10)
                self.croppedPhotos = self.photos.map({ (image) in
                    let sizeMin: CGFloat = min(image.size.width, image.size.height)
                    return image.cropTo(size: CGSize(width: sizeMin, height: sizeMin)).resizeTo(newSize: CGSize(width: 168, height: 168))
                })
        }
    }
}

//MARK: - Private methods
extension ScanVM {
    
    fileprivate func resolveInputFromCamera(sourceString: String) {
        do {
            let callback = try qrResolver.resolveQr(sourceString)
            captureSession.stopRunning()
            videoPreviewLayer.removeFromSuperlayer()
            delegate?.codeFound()
            callback(sourceString)
        } catch {
            delegate?.scanWrongSource(with: error.localizedDescription)
        }
    }
    
    fileprivate func resolveInputFromGallery(sourceString: String) {
        
        do {
            let callback = try qrResolver.resolveQr(sourceString)
            delegate?.codeFound()
            callback(sourceString)
            return
        } catch {
            delegate?.handleError(error: error.localizedDescription)
        }
    }
}

// MARK: UICollectionViewDataSource
extension ScanVM: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return croppedPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PickImageCell", for: indexPath) as! PickImageCell
        cell.imageView?.image = croppedPhotos[indexPath.row]
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension ScanVM: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pickedImage = photos[indexPath.row]
    }
}
