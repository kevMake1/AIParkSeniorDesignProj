//
//  HomeViewController.swift
//  AI Parking Detector
//
//  Created by Kevaughn Clarke on 10/7/20.
//

//image of parking lot design by <a href="http://www.freepik.com">Designed by macrovector / Freepik</a>

import UIKit
import CoreML
import Vision
import ImageIO

class HomeViewController: UIViewController {

   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
    }
    
//MARK:- Navigation
    
    //sattiteView
    @IBAction func satelliteViewBtnPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SatelliteView", sender: self)
    }
    

//    @IBAction func cameraBtnPressed(_ sender: UIButton) {
//        self.performSegue(withIdentifier: "CameraView", sender: self)
//    }
    
    //groundView
    @IBAction func groundViewBtnPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "groundView", sender: self)
    }
    
    //cameraView
    @IBAction func cameraBtnPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "CameraView", sender: self)
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
