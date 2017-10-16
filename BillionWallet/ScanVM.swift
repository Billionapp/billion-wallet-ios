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
    func codeDidFound(code: String)
    func handleError(error: String)
    func torchWasToggled(torchOn: Bool)
}

protocol PickVMDelegate: class {
    func cropDidEnd()
}

class ScanVM: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    private let scannerProvider: ScannerDataProvider
    
    var code: String {
        didSet {
            guard scannerProvider.scannedString != "" else {
                return
            }
            
            delegate?.codeDidFound(code: code)
            
        }
    }
    var torchOn: Bool {
        didSet {
            delegate?.torchWasToggled(torchOn: torchOn)
        }
    }
    weak var delegate: ScanVMDelegate?
    weak var pickDelegate: PickVMDelegate?
    let photoLibrary = PhotoLibrary()
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
                performQRCodeDetection(image: CIImage(image:image)!, success: { (detectedString) in
                    scannerProvider.scannedString = detectedString
                    code = detectedString
                }) { (errorString) in
                    delegate?.handleError(error: errorString)
                }
            }
        }
    }
    
    let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
    var captureSession = AVCaptureSession()
    var videoPreviewLayer = AVCaptureVideoPreviewLayer()
    let captureMetadataOutput = AVCaptureMetadataOutput()
    var rectOfInterest = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    
    init(provider: ScannerDataProvider) {
        self.code = ""
        self.scannerProvider = provider
        self.torchOn = false
    }
    
    func scanQrCode(view: UIView, rectOfInterest: CGRect) {
        
        addObserver()
        self.rectOfInterest = rectOfInterest
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession.addInput(input)
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
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
            let bundleName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String
            let cameraAccessError = String(format: "%@ is not allowed to access the camera, allow camera access in Settings->Privacy->Camera->%@", bundleName, bundleName)
            let popup = PopupView.init(type: .cancel, labelString: cameraAccessError)
            UIApplication.shared.keyWindow?.addSubview(popup)
            delegate?.codeDidFound(code: "")
            return
        }
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(avCaptureInputPortFormatDescriptionDidChangeNotification), name: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.captureSession.stopRunning()
        self.videoPreviewLayer.removeFromSuperlayer()
    }
    
    @objc func avCaptureInputPortFormatDescriptionDidChangeNotification(notification: NSNotification) {
        captureMetadataOutput.rectOfInterest = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: rectOfInterest)
    }
    
    // MARK: Capture delegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            if let address = metadataObj.stringValue {
                captureSession.stopRunning()
                videoPreviewLayer.removeFromSuperlayer()
                scannerProvider.scannedString = address
                code = address
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
                print("error")
            }
        }
    }
    
    // MARK: Picker Preparing
    func getPhotos() {
        DispatchQueue.global().async {
            self.photos = self.photoLibrary.getPhotos(10)
                self.croppedPhotos = self.photos.map({ (image) in
                    let sizeMin: CGFloat = min(image.size.width, image.size.height)
                    return image.cropTo(size: CGSize(width: sizeMin, height: sizeMin)).resizeTo(newSize: CGSize(width: 168, height: 168))
                })
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
