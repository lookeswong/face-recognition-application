//
//  FaceClassificationViewController.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 20/04/2021.
//

import UIKit
import AVKit
import Vision
import VideoToolbox
import CoreML
import RealmSwift

class FaceClassificationViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
//    let realm = try! Realm()
    var notificationToken: NotificationToken?
    var realm : Realm?
    var attendance : Results<Attendance>?
    var selectedSession : Session? {
        didSet {
            loadAttendance()
        }
    }
    var faceDetected: Bool = false
    let captureSession = AVCaptureSession()
    let cameraManager = CameraManager()
    var capturedFaceCount = 0
    
    let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .orange
        label.font = UIFont(name: "Avenir-Heavy", size: 30)
        label.text = "No face"
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupTabBar()
//        setupCamera()
        cameraManager.setupCamera(view: view, delegate: self)
        setupLabel()
    }
    
    // here is where we start the camera
//    func setupCamera() {
//        captureSession.sessionPreset = .high
//
//        guard let captureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else { preconditionFailure("A Camera is needed to start the AV session")  }
//
//        //throw error if no camera is found.
//        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
//        captureSession.addInput(input)
//
//        captureSession.startRunning()
//
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        view.layer.addSublayer(previewLayer)
//        previewLayer.frame = view.frame
//
//        let dataOutput = AVCaptureVideoDataOutput()
//        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
//        captureSession.addOutput(dataOutput)
//    }
    
    func setupLabel() {
        view.addSubview(label)
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        faceDetected = false
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: FaceClassifier().model) else {
                    fatalError("Unable to load model")
                }
        let ciImage = CIImage(cvImageBuffer: pixelBuffer, options: [:])
        detectFace(image: ciImage)
//        let detectFaceRequest = VNDetectFaceRectanglesRequest { (request, error) in
//            guard let faceResults = request.results as? [VNFaceObservation],
//                  let _ = faceResults.first
//            else {
//                print("no faces")
//                DispatchQueue.main.async {
//                    self.label.text = "no faces"
//                }
//                return
//            }
//            self.faceDetected = true
//            print("faceDetected is now true")
        if faceDetected == true {
            capturedFaceCount += 1
            print("capture face \(capturedFaceCount) times")
            classifyFace(image: pixelBuffer, model: model)
            if capturedFaceCount > 200 {
                DispatchQueue.main.async {
                    let newAttendance = Attendance(studentID: "test", studentName: self.label.text!, dateCreated: Date())
    //                newAttendance.studentName = self.label.text!
    //                newAttendance.studentID = "test"
    //                newAttendance.dateCreated = Date()
    //                self.saveAttendance(attendance: newAttendance)
                    
                    try! self.realm?.write {
                        self.selectedSession?.attendances.append(newAttendance)
                    }
                    print("attendance created")
                    self.captureSession.stopRunning()
                    return
                }
            }
            
//            guard let model = try? VNCoreMLModel(for: FaceClassifier().model) else {
//                        fatalError("Unable to load model")
//                    }

//            let coreMlRequest = VNCoreMLRequest(model: model) {[weak self] request, error in
//                guard let results = request.results as? [VNClassificationObservation],
//                    let topResult = results.first
//                    else {
//                        fatalError("Unexpected results")
//                }
//
//                print(topResult.identifier, topResult.confidence * 100)
//
//                DispatchQueue.main.async {[weak self] in
//                    self?.label.text = topResult.identifier
//                }
//            }
//
//            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
//            DispatchQueue.global().async {
//                do {
//                    try handler.perform([coreMlRequest])
//                } catch {
//                    print(error)
//                }
//            }
        } else {
            print("face detected is false")
        }
    }
        
//        let faceDetectionHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
//        do {
//            try faceDetectionHandler.perform([detectFaceRequest])
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
    
    //MARK: - Facial Recognition Method
    func classifyFace(image: CVPixelBuffer, model: VNCoreMLModel) {

        let coreMlRequest = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("Unexpected results")
            }

            print(topResult.identifier, topResult.confidence * 100)
            
            DispatchQueue.main.async {[weak self] in
                self?.label.text = topResult.identifier
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        DispatchQueue.global().async {
            do {
                try handler.perform([coreMlRequest])
            } catch {
                print("\(error.localizedDescription) classifyFace error")
            }
        }
    }
    
    func detectFace(image: CIImage){
        // try to detect face
        let detectFaceRequest = VNDetectFaceRectanglesRequest { (request, error) in
            guard let faceResults = request.results as? [VNFaceObservation], let _ = faceResults.first else {
                print("no faces")
                self.faceDetected = false
                DispatchQueue.main.async {
                    self.label.text = "no faces"
                }
                return
            }
            self.faceDetected = true
        }
        // initaite face detection requrest
        let faceDetectionHandler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            try faceDetectionHandler.perform([detectFaceRequest])
        } catch {
            print("\(error.localizedDescription) detectFace error")
        }
    }
    
    //MARK: - Data Manipulation Method
    func loadAttendance() {
        attendance = selectedSession?.attendances.sorted(byKeyPath: "studentID", ascending: true)
    }
    
//    func saveAttendance(attendance: Attendance) {
//        if let currentSession = selectedSession {
//            do {
//                try realm.write {
//                    currentSession.attendances.append(attendance)
//                }
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//    }

}
