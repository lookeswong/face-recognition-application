//
//  FaceTrackerViewController.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 21/04/2021.
//

import Foundation
import UIKit
import Vision
import AVFoundation
import FirebaseStorage
import FirebaseFirestore

class FaceTrackerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{

    let faceDetection = VNDetectFaceRectanglesRequest()
    let faceDetectionRequest = VNSequenceRequestHandler()
    var faceClassificationRequest: VNCoreMLRequest!
    var lastObservation : VNFaceObservation?
    let captureSession = AVCaptureSession()
    let cameraManager = CameraManager()

    private var sampleCounter = 0
    private let requiredSamples = 30
    private var faceImages = [UIImage]()
    private var isIdentifiyingPeople = false
    private var isCapturing: Bool = false
    var studentID : String?
    var studentName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        promptCommand()
        cameraManager.setupCamera(view: view, delegate: self)
//        setupCamera()
    }
    
//    func setupCamera() {
//        let captureSession = AVCaptureSession()
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
    
    // this function capture the output image frame by frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let attachments = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
          as? [CIImageOption: Any]
        else { return }
        let ciImage = CIImage(cvImageBuffer: pixelBuffer, options: attachments)
        let ciImageWithOrientation = ciImage.oriented(forExifOrientation: Int32(UIImage.Orientation.leftMirrored.rawValue))
        detectFace(on: ciImageWithOrientation)
    }
    
    // face detector
    func detectFace(on image: CIImage) {
        // try to detect face
        try? faceDetectionRequest.perform([faceDetection], on: image)
        
        guard let faceObservation = (faceDetection.results as? [VNFaceObservation])?.first else {
            print("no faces")
            return
        }
        // if no face is detected
        if isIdentifiyingPeople {
            // look for face again
            let handler = VNImageRequestHandler(ciImage: image, orientation: .up, options: [:])
            self.lastObservation = faceObservation
            try? handler.perform([self.faceClassificationRequest])
        } else { // if face detected, capture the image and upload the image to firebase with the firebase functions
            let faceImage: UIImage = convert(cmage: image)
            sampleCounter += 1
            if faceImages.count <= requiredSamples {
                if sampleCounter % 20 == 0 {
                    print(faceImages.count)
                    faceImages.append(faceImage)
                    uploadImages(image: faceImage) { (url) in
                        guard url != nil else { return }
                    }
                    print("+1")
                    }
            } else {
                print("enough data")
                DispatchQueue.main.async {
                    // go back to previous view controller after getting enough data
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
        }
    }
    
    //MARK:- Firebase method
    // upload image to firebase storage
    fileprivate func uploadImages(image: UIImage, completion: @escaping (_ url: String?) -> Void) {
        // convert UIImage to jpg format
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            // present error alert in device
            let alert = UIAlertController.init(title: "info", message: "something went wrong", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // create unique id for image
        let imageName = UUID().uuidString
        // create unique reference for image
        let imageReference = Storage.storage().reference().child("\(studentID!)_\(studentName!)").child("\(imageName).png")
        // upload image to firebase
        DispatchQueue.main.async {
            imageReference.putData(data, metadata: nil) {(metadata, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    completion(nil)
                } else {
                    imageReference.downloadURL(completion: { (url, error) in
                        print(url?.absoluteString as Any)
                        completion(url?.absoluteString)
                    })
                }
            }
        }
    }
    
    //MARK:- Image Conversion
    // function to convert image to UIImage format
    private func convert(cmage:CIImage) -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    //MARK:- Notification function
    private func promptCommand() {
        let alert = UIAlertController.init(title: "Info", message: "The system needs to capture your face images for training purposes. Please align your face at the centre of the screen and look at the camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
