//
//  CameraController.swift
//  CameraController
//
//  Created by Артём Зайцев on 18.03.2020.
//  Copyright © 2020 Артём Зайцев. All rights reserved.
//

import AVFoundation
import UIKit


class CameraController: NSObject {
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    var microphone: AVCaptureDevice?
    
    var currentCameraPosition: CameraPosition?
    var preferedCameraPosition: CameraPosition = .front
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    var audioInput: AVCaptureDeviceInput?
    
    var movieOutput: AVCaptureMovieFileOutput?
    var outputUrl: URL?
    var movieCapturedCompletionBlock: ((URL) -> Void)?
    var isRecording: Bool {
        guard let movieOutput = movieOutput else {
            return false
        }
        
        return movieOutput.isRecording
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    func prepare(completion: @escaping ((Error?) -> Void)) {
        self.clearConfiguration()
        
        DispatchQueue(label: "prepare").async {
            do {
                self.createCaptureSession()
                try self.configureCaptureDevices()
                try self.configureDeviceInputs()
                try self.configureVideoOutput()
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    func clearConfiguration() {
        if let audioInput = audioInput {
            captureSession?.removeInput(audioInput)
        }
        if let frontCameraInput = frontCameraInput {
            captureSession?.removeInput(frontCameraInput)
        }
        if let rearCameraInput = rearCameraInput {
            captureSession?.removeInput(rearCameraInput)
        }
        if let movieOutput = movieOutput {
            captureSession?.removeOutput(movieOutput)
        }
        
        captureSession = nil
        
        microphone = nil
        frontCamera = nil
        rearCamera = nil
        
        audioInput = nil
        frontCameraInput = nil
        rearCameraInput = nil
        
        previewLayer = nil
    }
    
    func createCaptureSession() {
        captureSession = AVCaptureSession()
    }
    
    func configureCaptureDevices() throws {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInMicrophone],
                                                       mediaType: AVMediaType.video,
                                                       position: .unspecified)
        let devices = session.devices
        if devices.isEmpty { throw CameraControllerError.noCamerasAvailable }
        
        for device in devices {
            if device.position == .front {
                frontCamera = device
            }
            
            if device.position == .back {
                rearCamera = device
                
                try device.lockForConfiguration()
                device.focusMode = .continuousAutoFocus
                device.unlockForConfiguration()
            }
        }
        microphone = AVCaptureDevice.default(for: .audio)
    }
    
    func configureDeviceInputs() throws {
        guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
        if let microphone = microphone {
            if audioInput == nil {
                audioInput = try AVCaptureDeviceInput(device: microphone)
            }

            if captureSession.canAddInput(audioInput!) {
                captureSession.addInput(audioInput!)
            }
        }
        
        if let rearCamera = self.rearCamera, preferedCameraPosition == .rear {
            if rearCameraInput == nil {
                rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            }
            
            if captureSession.canAddInput(rearCameraInput!) {
                captureSession.addInput(rearCameraInput!)
            }
            
            currentCameraPosition = .rear
        }
        
        else if let frontCamera = self.frontCamera, preferedCameraPosition == .front {
            if frontCameraInput == nil {
                frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            }
            
            if captureSession.canAddInput(frontCameraInput!) {
                captureSession.addInput(frontCameraInput!)
            } else {
                throw CameraControllerError.inputsAreInvalid
            }
            
            currentCameraPosition = .front
        }
        
        else {
            throw CameraControllerError.noCamerasAvailable
        }
    }
    
    func configureVideoOutput() throws {
        guard let captureSession = captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
        movieOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(movieOutput!) {
            captureSession.addOutput(movieOutput!)
        }
        
        captureSession.startRunning()
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = captureSession, captureSession.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        guard previewLayer == nil else {
            throw CameraControllerError.previewAlreadyBounded
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(previewLayer!, at: 0)
        previewLayer?.frame = view.frame
    }
    
    func captureVideo(completion: @escaping ((URL) -> Void)) throws {
        guard let captureSession = captureSession, captureSession.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        guard let movieOutput = movieOutput else {
            return
        }
        
        guard !movieOutput.isRecording else {
            throw CameraControllerError.alreadyCapturing
        }
        
        let connection = movieOutput.connection(with: .video)
        if (connection?.isVideoOrientationSupported)! {
            connection?.videoOrientation = .portrait
        }
        
        if (connection?.isVideoStabilizationSupported)! {
            connection?.preferredVideoStabilizationMode = .auto
        }
        
        outputUrl = tempURL()
        movieCapturedCompletionBlock = completion
        movieOutput.startRecording(to: outputUrl!, recordingDelegate: self)
    }
    
    func swapCamera() throws {
        guard let captureSession = captureSession else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        // clearing input
        if let rearCameraInput = rearCameraInput {
            captureSession.removeInput(rearCameraInput)
        }
        if let frontCameraInput = frontCameraInput {
            captureSession.removeInput(frontCameraInput)
        }
        
        preferedCameraPosition = (preferedCameraPosition == .front ? .rear : .front)
        
        DispatchQueue(label: "prepare").async {
            try? self.configureDeviceInputs()
        }
    }
    
    func stopCaptureVideo() throws {
        guard let captureSession = captureSession, captureSession.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        if (movieOutput?.isRecording)! {
            movieOutput?.stopRecording()
        }
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString

        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }

        return nil
    }
}


extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case alreadyCapturing
        case noOutputView
        case previewAlreadyBounded
        case unknown
    }
    
    enum CameraPosition {
        case front
        case rear
    }
}


extension CameraController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        movieCapturedCompletionBlock?(outputFileURL)
    }
}
