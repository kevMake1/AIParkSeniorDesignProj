//
//  ViewController.swift
//  AI Parking Detector
//
//  Created by Kevaughn Clarke on 7/14/20.
//

import UIKit
import CoreML
import Vision
import ImageIO

class SatelliteViewController: UIViewController, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    //Loading Model and setting requests
    lazy var detectionRequest: VNCoreMLRequest = {
        do{
            let model = try VNCoreMLModel(for: ParkingDetector_2().model)   //model
            
            let request = VNCoreMLRequest(model: model) { (req, error) in   //requests
                self.processDetections(for: req, error: error)
            }
            request.imageCropAndScaleOption = .scaleFit
            return request
        } catch{
            fatalError("Failed to load model")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
    }
    
//MARK:- process, draw, and update detections
    
    //process the detections
    private func processDetections(for req: VNRequest, error: Error?){
        
        DispatchQueue.main.async {
            //get the results
            guard let results = req.results else{
                print("Unable to detect anything.\n\(error!.localizedDescription)")
                return
            }
            
            //storing results as an array of VNRecognizedObjectObservation's
            let detections = results as! [VNRecognizedObjectObservation]
            
            //draw detections
            self.drawDetectionsOnPreview(detections: detections)
        }
    }
    
    func drawDetectionsOnPreview(detections: [VNRecognizedObjectObservation]){
        
        guard let image = self.imageView?.image else{ return }
        
        let imageSize = image.size
        let scale: CGFloat = 0 //scale
        
        //start UIGraphics context
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        
        //draws on img
        image.draw(at: CGPoint.zero)
        
        //print out info
        for detection in detections{
            print(detection.labels.map({"\($0.identifier) confidence: \($0.confidence)"}).joined(separator: "\n"))
            print("------------")
            

            // green for available spots, red for occupied spots
            if(detection.labels[0].identifier == "occupied parking spot"){
                let boundingBox = detection.boundingBox
                let rectangle = CGRect(x: boundingBox.minX*image.size.width, y: (1-boundingBox.minY-boundingBox.height)*image.size.height, width: boundingBox.width*image.size.width, height: boundingBox.height*image.size.height)
                UIColor(red: 1, green: 0, blue: 0, alpha: 0.4).setFill()
                UIRectFillUsingBlendMode(rectangle, CGBlendMode.normal)
            } else if(detection.labels[0].identifier == "available parking spot"){
                let boundingBox = detection.boundingBox
                let rectangle = CGRect(x: boundingBox.minX*image.size.width, y: (1-boundingBox.minY-boundingBox.height)*image.size.height, width: boundingBox.width*image.size.width, height: boundingBox.height*image.size.height)
                UIColor(red: 0, green: 1, blue: 0, alpha: 0.4).setFill()
                UIRectFillUsingBlendMode(rectangle, CGBlendMode.normal)
            }
            
            
            
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext() //end UIGraphics context
        
        self.imageView?.image = newImage
    }
    
    
    private func updateDetections(for image: UIImage){
        
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
        
        //converts the uiimage to a ciimage
        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to create \(CIImage.self) from \(image).")
        }
        
        //ciimage is passed to vnImageRequestHandler to perform the detections on images
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation!)
            
            do{
                try handler.perform([self.detectionRequest])
            } catch {
                print("Failed to update detection.\n\(error.localizedDescription)")
            }
        }
    }
    
    //MARK:- Buttons tapped
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}


//MARK:- Image Picker delegate

extension SatelliteViewController: UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else{ return }
        
        self.imageView?.image = image
        updateDetections(for: image)
    }
}







