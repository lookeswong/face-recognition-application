//
//  CameraManager.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 20/04/2021.
//

import Foundation
import AVKit

class CameraManager {
    
    let captureSession = AVCaptureSession()
    
    func setupCamera(view: UIView, delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        captureSession.sessionPreset = .high
        
        guard let captureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else { preconditionFailure("A Camera is needed to start the AV session")  }
        
        //throw error if no camera is found.
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
}
