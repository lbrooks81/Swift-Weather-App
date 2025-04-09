//
//  ViewController.swift
//  Weather App
//
//  Created by Logan on 3/31/25.
//

import UIKit
import SwiftUI
import CoreLocation


struct Response: Codable {
  
    
}

class ViewController: UIViewController {
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    let apiKey: String = "bfbf4f27dd5879cb9ed45a2afb2f7b8b"
    let apiEndpoint: String = "https://api.openweathermap.org/data/3.0/onecall/?lat=\(latitude)&lon=\(longitude)"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let labelVC = segue.destination as? DayView{
            switch segue.identifier {
            case "One":
                break
            case "Two":
                break
            case "Three":
                break
            case "Four":
                break
            case "Five":
                break
            case "Six":
                break
            case "Seven":
                break
            default:
                break
            }
        }
    }
}

class DayView: UIViewController {
    @IBOutlet var lowHighTempLabel: UILabel!
    @IBOutlet var weatherDescriptionLabel: UILabel!
    @IBOutlet var chanceOfPrecipitationLabel: UILabel!
    @IBOutlet var currentTempLabel: UILabel!
}


