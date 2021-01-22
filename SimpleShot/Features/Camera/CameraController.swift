//
//  CameraController.swift
//  SimpleShot
//
//  Created by Paulo Inocencio on 01/01/21.
//

import AVFoundation
import UIKit

class CameraController: NSObject {
    
    // Capture Session
    let session = AVCaptureSession()
    
    // Capture Device
    var backFacingCamera: AVCaptureDevice?
    var frontFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice!
    
    // Capture Outputs
    var photoOutput = AVCapturePhotoOutput()
    var videoFileOutput = AVCaptureMovieFileOutput()
    
    // Capture Preview
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private var photoCaptureCompletionBlock: ((Result<UIImage, Error>) -> Void)?
    private var videoRecordingCompletionBlock : ((Result<URL, Error>) -> Void)?
    
    private let sessionQueue = DispatchQueue(label: "session queue")
}

extension CameraController {
    
    func prepareSession(completion: @escaping (Error?) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion(CameraControllerError.unknown) }
                return
            }
            
            self.session.beginConfiguration()
            
            // Achieve high resolution photo quality output as default
            self.session.sessionPreset = .photo
            
            
            // Get the font and back-facing camera for taking photos
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
            for device in deviceDiscoverySession.devices {
                if device.position == .back {
                    self.backFacingCamera = device
                } else if device.position == .front {
                    self.frontFacingCamera = device
                }
            }
            self.currentDevice = self.backFacingCamera
            
            
            // Add video input.
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: self.currentDevice) else {
                DispatchQueue.main.async { completion(CameraControllerError.inputIsInvalid) }
                return
            }
            if self.session.canAddInput(videoDeviceInput) {
                self.session.addInput(videoDeviceInput)
            } else {
                DispatchQueue.main.async { completion(CameraControllerError.inputIsInvalid) }
                return
            }
            
            
            // Add an audio input device.
            let audioDevice = AVCaptureDevice.default(for: .audio)
            guard let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice!) else {
                DispatchQueue.main.async { completion(CameraControllerError.inputIsInvalid) }
                return
            }
            if self.session.canAddInput(audioDeviceInput){
                self.session.addInput(audioDeviceInput)
            } else {
                DispatchQueue.main.async { completion(CameraControllerError.inputIsInvalid) }
                return
            }
            
            
            // Add photo output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            } else {
                DispatchQueue.main.async { completion(CameraControllerError.outputIsInvalid) }
               return
            }
            
            // Add video output
            if self.session.canAddOutput(self.videoFileOutput) {
                self.session.addOutput(self.videoFileOutput)
            } else {
                DispatchQueue.main.async { completion(CameraControllerError.outputIsInvalid) }
            }
            
            self.session.commitConfiguration()
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    
    func changeToVideoCapture(completion: @escaping (Error?) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion(CameraControllerError.unknown) }
                return
            }
            
            // Achieve high quality video and audio output
            self.session.beginConfiguration()
            self.session.sessionPreset = .high
            self.session.commitConfiguration()
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    
    
    func changeToPhotoCapture(completion: @escaping (Error?) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion(CameraControllerError.unknown) }
                return
            }
            
            // Achieve high resolution photo quality output
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            self.session.commitConfiguration()
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    

    func displayPreview(on view: UIView) {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraPreviewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(self.cameraPreviewLayer!)
        self.cameraPreviewLayer?.frame = view.frame
        session.startRunning()
    }
    
    
    
    func takePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) {
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        self.photoOutput.isHighResolutionCaptureEnabled = true
        self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
    
    
    func startRecording() {
        let outputPath = NSTemporaryDirectory() + "output.mov"
        let outputFileURL = URL(fileURLWithPath: outputPath)
        self.videoFileOutput.startRecording(to: outputFileURL, recordingDelegate: self)
    }
    
    
    
    func finishRecording(completion: @escaping (Result<URL, Error>) -> Void) {
        self.videoRecordingCompletionBlock = completion
        self.videoFileOutput.stopRecording()
    }
    
    
    func flipOverCamera(completion: @escaping (Error?) -> Void) {
        session.beginConfiguration()
        guard let newDevice = (currentDevice.position == .back) ? frontFacingCamera : backFacingCamera else {
            completion(CameraControllerError.noCamerasAvailable)
            return
        }
        
        for input in session.inputs {
            session.removeInput(input as! AVCaptureDeviceInput)
        }
        
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: newDevice) else {
            completion(CameraControllerError.inputIsInvalid)
            return
        }
        
        session.addInput(captureDeviceInput)
        currentDevice = newDevice
        session.commitConfiguration()
        completion(nil)
    }
    

}


extension CameraController : AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            photoCaptureCompletionBlock?(.failure(error!))
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            photoCaptureCompletionBlock?(.failure(CameraControllerError.couldNotGetData))
            return
        }
        
        guard let image = UIImage(data: imageData) else {
            photoCaptureCompletionBlock?(.failure(CameraControllerError.couldNotGenerateImage))
            return
        }
        
        photoCaptureCompletionBlock?(.success(image))
    }
}



extension CameraController : AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            self.videoRecordingCompletionBlock?(.failure(error!))
            return
        }
        
        videoRecordingCompletionBlock?(.success(outputFileURL))
    }
}


extension CameraController {
    enum CameraControllerError: Error {
        case captureSessionAlreadyRunning
        case inputIsInvalid
        case outputIsInvalid
        case invalidOperation
        case couldNotGetData
        case couldNotGenerateImage
        case noCamerasAvailable
        case unknown
    }
}
