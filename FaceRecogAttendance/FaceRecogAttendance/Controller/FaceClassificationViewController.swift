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
    
    var realm : Realm?
    var attendance : Results<Attendance>?
    var selectedSession : Session? {
        didSet {
            loadAttendance()
        }
    }
    
    let captureSession = AVCaptureSession()
    let cameraManager = CameraManager()
    
    private var capturedFaceCount = 0
    private var faceDetected: Bool = false
    private var verification: Bool = false
    
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
        cameraManager.setupCamera(view: view, delegate: self)
        setupLabel()
    }
    
    // setup label at the bottom of the screen
    func setupLabel() {
        view.addSubview(label)
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    // function to capture every image frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.verification = false
        self.faceDetected = false
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        // initiate the face recognition model
        guard let model = try? VNCoreMLModel(for: FaceClassifierV3().model) else {
                    fatalError("Unable to load model")
                }
        let ciImage = CIImage(cvImageBuffer: pixelBuffer, options: [:])
        // detect face in the image
        detectFace(image: ciImage)
        if faceDetected == true {
            capturedFaceCount += 1
            print("capture face \(capturedFaceCount) times")
            classifyFace(image: pixelBuffer, model: model)
            // if the correct face is identified, create attendance
            if capturedFaceCount == 100 {
                DispatchQueue.main.async {
                    let alert = UIAlertController.init(title: "Verify", message: "\(self.label.text!)%, please confirm", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { (action) in
                        self.verification = true
                        print("verification is now true")
                        self.navigationController?.popToRootViewController(animated: true)
                    }))
                    alert.addAction(UIAlertAction.init(title: "No", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    if self.verification == true {
                        let name = self.label.text!.components(separatedBy: "-").first!
                        print(name)
                        let newAttendance = Attendance(studentID: "test", studentName: name, dateCreated: Date())
                        
                        try! self.realm?.write {
                            self.selectedSession?.attendances.append(newAttendance)
                        }
                        print("attendance created")
                        self.cameraManager.captureSession.stopRunning()
                            return
                    }
                }
            }
        } else {
            print("face detected is false")
        }
    }
    
    //MARK: - Facial Recognition Method
    // function to classify faces
    func classifyFace(image: CVPixelBuffer, model: VNCoreMLModel) {

        let coreMlRequest = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("Unexpected results")
            }

            print(topResult.identifier, topResult.confidence * 100)
            
            DispatchQueue.main.async {[weak self] in
                self?.label.text = "\(topResult.identifier) - \(topResult.confidence * 100)"
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
    
    // function to detect faces
    func detectFace(image: CIImage){
        // try to detect face
        let detectFaceRequest = VNDetectFaceRectanglesRequest { (request, error) in
            guard let faceResults = request.results as? [VNFaceObservation], let _ = faceResults.first else {
                print("no faces")
                self.capturedFaceCount = 0
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

}
