//
//  CameraViewController.swift
//  AI Parking Detector
//
//  Created by Kevaughn Clarke on 10/7/20.
//

import UIKit
import AVFoundation
import Vision

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {


    @IBOutlet var cameraView: UIView!
    @IBOutlet weak var label: UILabel!
    
    //set up the handler for the captured images
    private let visionSequenceHandler = VNSequenceRequestHandler()
    
    //set up camera preview layer
    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    
    //set up capture session
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        //set up the back camera as the device to take images from
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
        let input = try? AVCaptureDeviceInput(device: backCamera)
        else {
            print("no camera is available.");
            return session
        }
        
        // add the rear camera as the capture device
        session.addInput(input)
        return session
        }()
    
//MARK:- ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add the camera preview
        self.cameraView?.layer.addSublayer(self.cameraLayer)

        // set up the delegate to handle the images to be fed to Core ML
        let videoOutput = AVCaptureVideoDataOutput()

        // we want to process the image buffer and ML off the main thread
        videoOutput.setSampleBufferDelegate(self,
        queue: DispatchQueue(label: "DispatchQueue"))

        self.captureSession.addOutput(videoOutput)

        // make the camera output fill the screen
        cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        // begin the session
        self.captureSession.startRunning()
        
    }
    
    //To make sure the viewfinder fills the screen, add a viewDidLayoutSubviews override
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // make sure the layer is the correct size
        self.cameraLayer.frame = (self.cameraView?.frame)!
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        // Get the pixel buffer from the capture session
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // load the Core ML model
        guard let visionModel:VNCoreMLModel = try? VNCoreMLModel(for: GroundView().model) else { return }

        //  set up the classification request
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleClassification)

        // automatically resize the image from the pixel buffer to fit what the model needs
        //classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOptionCenterCrop

        // perform the machine learning classification
        do {
            try self.visionSequenceHandler.perform([classificationRequest], on: pixelBuffer)
        } catch {
            print("Throws: \(error)")
        }
    }
    
    
    
    func updateClassificationLabel(labelString: String) {
    // We processed the capture session and Core ML off the main thread, so the completion handler was called onthe the same thread
    // So we need to remember to get the main thread again to update the UI

        DispatchQueue.main.async {
            self.label?.text = labelString
        }
    }

    func textForClassification(classification: VNClassificationObservation) -> String {
        // Mapping the results from the VNClassificationObservation to a human readable string
        let pc = Int(classification.confidence * 100)
        return "\(classification.identifier)\nConfidence: \(pc)%"
    }
    
    
    
    func handleClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results else {

            // Nothing has been returned so we want to clear the label.
            updateClassificationLabel(labelString: "")

            return
        }

        let classifications = observations //taking just the top 3, ignoring the rest
            .compactMap({ $0 as? VNClassificationObservation}) // discard any erroneous results
            .filter({ $0.confidence > 0.2 }) // discard anything with less than 20% accuracy.
            .map(self.textForClassification) // get the text to display
        // Filter further here if you're looking for specific objects

        if (classifications.count > 0) {
            // update the label to display what we found
            updateClassificationLabel(labelString: "\(classifications.joined(separator: "\n"))")
        } else {
            // nothing matches our criteria, so clear the label
            updateClassificationLabel(labelString: "")
        }
    }
   
    

    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
