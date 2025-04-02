//
//  ViewController.swift
//  Weather App
//
//  Created by Logan on 3/31/25.
//

import UIKit
import SwiftUI

struct WeatherData: View{
    var Date: String
    var lowTemp: String
    var highTemp: String
    var currentTemp: String
    
    var body: some View{
        Button: {
            Text(Date)
            do:{
                
            }
        }
        Text(lowTemp + "/" + highTemp)
        Text(currentTemp)
    }
}

class ViewController: UIViewController {

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}


