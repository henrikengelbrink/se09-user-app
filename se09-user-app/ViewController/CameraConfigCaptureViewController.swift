//
//  CameraConfigCaptureViewController.swift
//  se09-user-app
//
//  Created by Henrik Engelbrink on 20.03.20.
//  Copyright © 2020 Henrik Engelbrink. All rights reserved.
//

import UIKit
import AVFoundation
import QuickLook
import Vision

class CameraConfigCaptureViewController: UIViewController, AVCapturePhotoCaptureDelegate {
            
    @IBOutlet private weak var cameraView: UIView!
    @IBOutlet var captureButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    private var stillImageOutput: AVCapturePhotoOutput!
    private var session: AVCaptureSession? = nil
    
    private var userDeviceId: String? = nil
    private var password: String? = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(goBack))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(self.session == nil) {
            self.requestCamera()
        } else {
            self.session!.startRunning()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        if(self.session != nil) {
            self.session!.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func requestCamera() {
        let cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if cameraPermissionStatus == AVAuthorizationStatus.notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                DispatchQueue.main.async {
                    if response {
                        self.setupCamera()
                    } else {
                        print("MIssing Camera Auth")
                    }
                }
            }
        } else if cameraPermissionStatus == AVAuthorizationStatus.denied {
            print("MIssing Camera Auth")
        } else if cameraPermissionStatus == AVAuthorizationStatus.authorized {
            self.setupCamera()
        }
    }
    
    func setupCamera() {
        let captureDevice: AVCaptureDevice? = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        if(captureDevice != nil) {
            do {
                let deviceInput: AVCaptureInput = try AVCaptureDeviceInput(device: captureDevice!) as AVCaptureInput
                self.stillImageOutput = AVCapturePhotoOutput()
                self.session = AVCaptureSession()
                self.session!.sessionPreset = AVCaptureSession.Preset.photo
                self.session!.addInput(deviceInput as AVCaptureInput)
                self.session!.addOutput(self.stillImageOutput)
                let previewLayer = self.cameraPreviewLayer()
                self.cameraView.layer.addSublayer(previewLayer)
                self.session!.startRunning()
            }
            catch {
                print("SETUP CAMERA ERROR")
            }
        }
    }
    
    private func cameraPreviewLayer() -> AVCaptureVideoPreviewLayer {
        let previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session!) as AVCaptureVideoPreviewLayer
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        let point = CGPoint(x: 0, y: 0)
        let size = self.cameraView.frame.size
        previewLayer.frame = CGRect(origin: point, size: size)
        previewLayer.backgroundColor = UIColor.green.cgColor
        return previewLayer
    }
    
    @IBAction func takeImage(_ sender: Any) {
        self.activityIndicator.isHidden = false
        self.captureButton.isEnabled = false
        if (self.stillImageOutput.connection(with: AVMediaType.video) != nil) {
            let captureSettings = AVCapturePhotoSettings()
            
            let previewPixelType = captureSettings.availablePreviewPhotoPixelFormatTypes.first!
            let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                 kCVPixelBufferWidthKey as String: self.cameraView.frame.width,
                                 kCVPixelBufferHeightKey as String: self.cameraView.frame.height] as [String : Any]
            captureSettings.previewPhotoFormat = previewFormat
            
            self.stillImageOutput.capturePhoto(with: captureSettings, delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let imageData = photo.fileDataRepresentation()
        if(imageData != nil) {
            let image = UIImage(data: imageData!)
            
            let imageWidth = image!.size.width
            let imageHeight = image!.size.height
            let scale = imageWidth / self.cameraView.frame.width
            let cropHeight = self.cameraView.frame.height * scale
            let x = (imageHeight / 2) - (cropHeight / 2)
            
            let rect = CGRect(x: x, y: 0, width: cropHeight, height: imageWidth)
            let imageRef = image?.cgImage?.cropping(to: rect)
            let croppedImage = UIImage(cgImage: imageRef!, scale: 1, orientation: image!.imageOrientation)
            let rotatedImage = fixOrientationOfImage(image: croppedImage)

            let cgImage = rotatedImage?.cgImage
            var id = ""
            let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
               guard let observations = request.results as? [VNRecognizedTextObservation] else {
                   print("The observations are of an unexpected type.")
                   return
               }
               let maximumCandidates = 1
               for observation in observations {
                   guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                    id = "\(id)\(candidate.string)"
               }
            }
            textRecognitionRequest.recognitionLevel = .accurate

            let requestHandler = VNImageRequestHandler(cgImage: cgImage!, options: [:])
            do {
                try requestHandler.perform([textRecognitionRequest])
            } catch {
                print(error)
            }
            print("**** SCANNED \(id)")
//            let lowerCaseId = id.lowercased()
            let lowerCaseId = "668fb2a2-6609-4450-8a59-c44cc030205b"
            let alert = UIAlertController(title: "Id correct ?", message: lowerCaseId, preferredStyle: .actionSheet)
            let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (action) in
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WifiViewController") as! WifiViewController
                vc.deviceId = lowerCaseId
                self.navigationController?.pushViewController(vc, animated: true)
            }
            let noAction = UIAlertAction.init(title: "No", style: .destructive) { (action) in
                self.captureButton.isEnabled = true
                self.activityIndicator.isHidden = true
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func fixOrientationOfImage(image: UIImage) -> UIImage? {
        if image.imageOrientation == .up {
            return image
        }

        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity

        switch image.imageOrientation {
           case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by:  CGFloat(Double.pi / 2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by:  -CGFloat(Double.pi / 2))
        default:
            break
        }

        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }

        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue) else {
            return nil
        }

        context.concatenate(transform)

        switch image.imageOrientation {
          case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
           default:
              context.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size))
        }

        // And now we just create a new UIImage from the drawing context
        guard let CGImage = context.makeImage() else {
            return nil
        }

        return UIImage(cgImage: CGImage)
    }
    

}
