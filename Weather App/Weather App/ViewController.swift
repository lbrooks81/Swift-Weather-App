//
//  ViewController.swift
//  Weather App
//
//  Created by Logan on 3/31/25.
//

import UIKit
import SwiftUI
import CoreLocation

var days = [DayView]()

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
        let precipitation_probability_mean: [Float]
        let cloud_cover_mean: [Float]
        let wind_speed_10m_max: [Float]
        let wind_direction_10m_dominant: [Float]
    }
}

// Todo: Initialize 7 DayView objects to put the weatherdata into when it is fetched


class ViewController: UIViewController, CLLocationManagerDelegate {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locManager = CLLocationManager()
        locManager.delegate = self
        locManager.startMonitoringSignificantLocationChanges()
        locManager.requestLocation()
            
        fetchWeatherData()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.first {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            // Handle location update
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Handle failure to get a user’s location
        print(error)
    }



    
    
    func fetchWeatherData()
    {
        // let apiKey: String = "bfbf4f27dd5879cb9ed45a2afb2f7b8b"
        // let urlString: String = "https://api.openweathermap.org/data/3.0/onecall/?lat=40.79&lon=77.86&appid=\(apiKey)"
        
        let urlString: String = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=temperature_2m_max,temperature_2m_min,wind_speed_10m_max,wind_direction_10m_dominant,precipitation_probability_mean,cloud_cover_mean&current=temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,wind_direction_10m&wind_speed_unit=mph&temperature_unit=fahrenheit&precipitation_unit=inch"
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
                    self.processData(data: weatherResponse)
                }
                
            }
            catch
            {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
    

    func processData(data: WeatherData){
        for day in days{
            let index = days.firstIndex(of: day)!
            
            day.lowHighTempLabel.text =
            "\(data.daily.temperature_2m_min[index])° / \(data.daily.temperature_2m_max[index])°"
            
            day.weatherDescriptionLabel.text = getWeatherDescription(data: data, day: index)
            
            let unroundedTemp = (data.daily.temperature_2m_max[index] + data.daily.temperature_2m_min[index]) / 2
            let currentTemp = round(unroundedTemp * 100) / 100
            
            day.currentTempLabel.text = "\(currentTemp)°"
            
            day.chanceOfPrecipitationLabel.text = "\(data.daily.precipitation_probability_mean[index])% chance of \(currentTemp >= 32 ? "rain" : "snow")"
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            
            let dayOfWeek = dateFormatter.string(from: Date().addingTimeInterval(TimeInterval(86400 * index)))
        
            day.viewDetailsButton.setTitle(dayOfWeek, for: .normal)
        }
    }

    func getWeatherDescription(data: WeatherData, day: Int) -> String {
        let cloudCover = data.daily.cloud_cover_mean[day]
        let precipitationProbability = data.daily.precipitation_probability_mean[day]
        let unroundedTemp = (data.daily.temperature_2m_max[day] + data.daily.temperature_2m_min[day]) / 2
        let temp = round(unroundedTemp * 100) / 100
        
        var weatherDescription = ""
        
        if (precipitationProbability >= 55) {
            if (temp <= 32) {
                weatherDescription = "Snow"
            } else {
                weatherDescription = "Rain"
            }
        } else if (cloudCover >= 55) {
            weatherDescription = "Cloudy"
        } else {
            weatherDescription = "Sunny"
        }
        return weatherDescription
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let labelVC = segue.destination as? DayView{
            days.append(labelVC)
            print(days.count)
        }
    }
}

class DayView: UIViewController {
    @IBOutlet var lowHighTempLabel: UILabel!
    @IBOutlet var weatherDescriptionLabel: UILabel!
    @IBOutlet var chanceOfPrecipitationLabel: UILabel!
    @IBOutlet var currentTempLabel: UILabel!
    @IBOutlet var viewDetailsButton: UIButton!
    @IBAction func viewDetails(){
        
    }
}


