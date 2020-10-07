//
//  HomeViewController.swift
//  AI Parking Detector
//
//  Created by Kevaughn Clarke on 10/7/20.
//

import UIKit
import CoreML
import Vision
import ImageIO

class HomeViewController: UIViewController {

   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
//MARK:- Navigation
    
    @IBAction func satelliteViewBtnPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SatelliteView", sender: self)
    }
    

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
