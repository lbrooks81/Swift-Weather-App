//
//  ViewController.swift
//  Weather App
//
//  Created by Logan on 3/31/25.
//

import UIKit
import SwiftUI
import CoreLocation

let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max,wind_direction_10m_dominant&current=temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,wind_direction_10m&wind_speed_unit=mph&temperature_unit=fahrenheit&precipitation_unit=inch&format=flatbuffers")!


struct WeatherData: Codable {
    let current: Current
    let daily: Daily

    struct Current: Codable {
        let temperature_2m: Float
        let relative_humidity_2m: Float
        let precipitation: Float
        let wind_speed_10m: Float
        let wind_direction_10m: Float
    }
    struct Daily: Codable {
        let temperature_2m_max: [Float]
        let temperature_2m_min: [Float]
        let precipitation_probability_max: [Float]
        let wind_speed_10m_max: [Float]
        let wind_direction_10m_dominant: [Float]
    }
}

let DayOne: DayView



class ViewController: UIViewController {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // getLocation()
        fetchWeatherData()
    }
    
    func getLocation() {
        locManager.startMonitoringSignificantLocationChanges()
        
        locManager.requestWhenInUseAuthorization()
        
        currentLocation = locManager.location
        
        latitude = currentLocation.coordinate.latitude
        longitude = currentLocation.coordinate.longitude
    }
    
    
    
    func fetchWeatherData()
    {
        // let apiKey: String = "bfbf4f27dd5879cb9ed45a2afb2f7b8b"
        // let urlString: String = "https://api.openweathermap.org/data/3.0/onecall/?lat=40.79&lon=77.86&appid=\(apiKey)"
        
        let urlString: String = "https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max,wind_direction_10m_dominant&current=temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,wind_direction_10m&wind_speed_unit=mph&temperature_unit=fahrenheit&precipitation_unit=inch"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error
            {
                print("Error fetching data: \(error)")
                return
            }
            guard let data = data else { return }
            do
            {
                let decoder = JSONDecoder()
                
                let weatherResponse = try decoder.decode(WeatherData.self, from: data)
                
                DispatchQueue.main.async{
                    
                }
            }
            catch
            {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
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
    
    func updateUI(with weatherData: WeatherData) {
        lowHighTempLabel.text = "\(weatherData.daily.temperature_2m_min)° / \(weatherData.daily.temperature_2m_max)°"
        chanceOfPrecipitationLabel.text = "\(weatherData.daily.precipitation_probability_max)%"
        currentTempLabel.text = "\(weatherData.current.temperature_2m)°"
    }
}


