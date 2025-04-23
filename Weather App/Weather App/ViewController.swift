//
//  ViewController.swift
//  Weather App
//
//  Created by Logan on 3/31/25.
//

import UIKit
import CoreLocation

var days = [DayView]()
var weatherData: WeatherData!

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
        let temperature_2m_mean: [Float]
        let precipitation_probability_mean: [Float]
        let cloud_cover_mean: [Float]
        let wind_speed_10m_mean: [Float]
        let wind_direction_10m_dominant: [Float]
        let relative_humidity_2m_mean: [Float]
        let weather_code: [Int]
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    var currentLocation: CLLocation!
    let locManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locManager.startUpdatingLocation()
        }
        
        setBackgroundImage(viewController: self)
        
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.first {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            
            fetchWeatherData()
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Handle failure to get a user’s location
        print(error)
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("Not determined")
        case .restricted:
            print("Restricted")
        case .denied:
            print("Denied")
        case .authorizedAlways, .authorizedWhenInUse:
            print("Access granted")
            locManager.requestLocation()
        @unknown default:
            print("Unknown authorization status")
        }
    }
    
    func fetchWeatherData()
    {
        let urlString: String = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=temperature_2m_min,temperature_2m_max,temperature_2m_mean,weather_code,wind_speed_10m_mean,wind_direction_10m_dominant,precipitation_probability_mean,cloud_cover_mean,weather_code,relative_humidity_2m_mean&current=temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,wind_direction_10m&wind_speed_unit=mph&temperature_unit=fahrenheit&precipitation_unit=inch"
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
                    weatherData = weatherResponse
                    self.updateUI(data: weatherResponse)
                    for day in days {
                        print("Tag: \(day.view.tag)")
                    }
                }
                
            }
            catch
            {
                print("Error decoding JSON: \(error)")
            }
        }
        
        task.resume()
    }
    
    // Updates the UI with the weather data for each day
    func updateUI(data: WeatherData){
        for (index, day) in days.enumerated(){
            
            // Low and High Temperature
            day.lowHighTempLabel.text =
            "H:\(data.daily.temperature_2m_min[index])° L: \(data.daily.temperature_2m_max[index])°"
            
            // Weather Description f
            let weatherDescription = getWeatherDescription(code: data.daily.weather_code[index], day: index)
            day.weatherDescriptionLabel.text = weatherDescription
            
            // Average Temp
            let unroundedTemp = data.daily.temperature_2m_mean[index]
            let averageTemp = round(unroundedTemp * 100) / 100
            day.averageTempLabel.text = "\(averageTemp)°"
            
            // Precipitation
            day.chanceOfPrecipitationLabel.text = "\(data.daily.precipitation_probability_mean[index])% precipitation chance"
            
            // Set the Day of the Week
            let calendar = Calendar.current
            let currentDate = Date()
            if let futureDate = calendar.date(byAdding: .day, value: index, to: currentDate) {
                // Format the future date to get the day of the week
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                let dayOfWeek = dateFormatter.string(from: futureDate)

                day.dayLabel.text = dayOfWeek
            }
            
            day.updateWeatherIcon(description: weatherDescription)
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // Set the tag for the days to be the identifier name
        if let identifier = segue.identifier, let tag = Int(identifier) {
            if let labelVC = segue.destination as? DayView {
                // Ensure no duplicates when adding days to the array
                if(!days.contains(labelVC)) {
                    labelVC.view.tag = tag
                    days.append(labelVC)
                }
                days.sort {
                    $0.view.tag < $1.view.tag
                }
            }
        }
    }
}

class DayView: UIViewController {
    @IBOutlet var lowHighTempLabel: UILabel!
    @IBOutlet var weatherDescriptionLabel: UILabel!
    @IBOutlet var chanceOfPrecipitationLabel: UILabel!
    @IBOutlet var averageTempLabel: UILabel!
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var icon: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadViewIfNeeded()
        icon.contentMode = .scaleAspectFit
        
    }
    
    // Handles the button press to view the details of the selected day
    @IBAction func viewDetails() {
        if self.parent is ViewController {
            let dayIndex = days.firstIndex(of: self) ?? 0
            self.performSegue(withIdentifier: "DetailsController", sender: dayIndex)
        }
    }
    
    // Updates the weather icon based on the weather description
    func updateWeatherIcon(description: String) {
        let imageName: String
        switch description {
            case "Clear sky":
                imageName = "clear-sky"
            case "Mainly clear":
                imageName = "mainly-clear"
            case "Partly cloudy":
                imageName = "partly-cloudy"
            case "Overcast":
                imageName = "overcast"
            case "Fog", "depositing rime fog":
                imageName = "fog"
            case "Light drizzle", "Moderate drizzle", "Dense intensity drizzle":
                imageName = "drizzle"
            case "Light rain", "Moderate rain", "Heavy rain", "Slight rain showers", "Moderate rain showers", "Violent rain showers":
                    imageName = "rainy.png"
            case "Light snowfall", "Moderate snowfall", "Heavy snowfall", "Slight snow showers", "Heavy snow showers":
                imageName = "snowy"
            default:
                imageName = "cloudy"
        }
        icon.image = UIImage(named: imageName)
    }
    
    // Allows the data from the button to be passed to the details view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "DetailsController" {
            if let detailsVC = segue.destination as? DetailsView, let dayIndex = sender as? Int {
                detailsVC.day = dayIndex % 7
                detailsVC.iconImage = self.icon.image
                detailsVC.weatherDescription = self.weatherDescriptionLabel.text
            }
        }
    }
}

    
class DetailsView: UIViewController {
    @IBOutlet var windSpeedLabel: UILabel!
    @IBOutlet var windDirectionLabel: UILabel!
    
    @IBOutlet var humidityLabel: UILabel!
    
    @IBOutlet var precipitationPercentageLabel: UILabel!
    @IBOutlet var precipitationTimeLabel: UILabel!
    
    @IBOutlet var averageTemperatureLabel: UILabel!
    @IBOutlet var lowHighTempLabel: UILabel!
    
    @IBOutlet var weatherDescriptionLabel: UILabel!
    var weatherDescription: String!
    
    @IBOutlet var icon: UIImageView!
    var iconImage: UIImage!
    
    @IBAction func backButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    var data: WeatherData!
    var day: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherDescriptionLabel.text = weatherDescription
        icon.image = iconImage
        
        updateLabels()
        setBackgroundImage(viewController: self)
    }
    
    // Updates the labels with the weather data for the selected day
    func updateLabels()
    {
        // Set humidity label
        humidityLabel.text = "\(weatherData.daily.relative_humidity_2m_mean[self.day])%"
        // Set precipitation label
        precipitationPercentageLabel.text = "\(weatherData.daily.precipitation_probability_mean[self.day])%"
        // Set wind labels
        windDirectionLabel.text =                          "\(getWindDirection())"
        windSpeedLabel.text = "\(weatherData.daily.wind_speed_10m_mean[self.day])mph"
        // Set temperature label
        averageTemperatureLabel.text = "\(weatherData.daily.temperature_2m_mean[self.day])°"
        lowHighTempLabel.text =
        "H:\(weatherData.daily.temperature_2m_min[self.day])° L: \(weatherData.daily.temperature_2m_max[self.day])°"
    }
    
    // Converts the wind direction into cardinal directions based on the degrees
    func getWindDirection() -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((weatherData.daily.wind_direction_10m_dominant[self.day] + 22.5) / 45.0) % 8
        return directions[index]
    }
}

// Sets the background image for a view controller that's passed in
func setBackgroundImage(viewController: UIViewController) {
    let backgroundImage = UIImageView(frame: viewController.view.bounds)
    backgroundImage.image = UIImage(named: "background")
    backgroundImage.contentMode = .scaleAspectFill
    viewController.view.addSubview(backgroundImage)
    viewController.view.sendSubviewToBack(backgroundImage)
}


// Returns the weather description based on weather data passed in
func getWeatherDescription(code: Int, day: Int) -> String {
    var weatherDescription: String
    switch code {
        case 0:
            weatherDescription = "Clear sky"
        case 1:
            weatherDescription = "Mainly clear"
        case 2:
            weatherDescription = "Partly cloudy"
        case 3:
            weatherDescription = "Overcast"
        case 45:
            weatherDescription = "Fog"
        case 48:
            weatherDescription = "Depositing rime fog"
        case 51:
            weatherDescription = "Light drizzle"
        case 53:
            weatherDescription = "Moderate drizzle"
        case 55:
            weatherDescription = "Dense intensity drizzle"
        case 56:
            weatherDescription = "Light freezing drizzle"
        case 57:
            weatherDescription = "Dense freezing drizzle"
        case 61:
            weatherDescription = "Slight rain"
        case 63:
            weatherDescription = "Moderate rain"
        case 65:
            weatherDescription = "Heavy rain"
        case 66:
            weatherDescription = "Light freezing rain"
        case 67:
            weatherDescription = "Heavy freezing rain"
        case 71:
            weatherDescription = "Slight snowfall"
        case 73:
            weatherDescription = "Moderate snowfall"
        case 75:
            weatherDescription = "Heavy snowfall"
        case 77:
            weatherDescription = "Snow grains"
        case 80:
            weatherDescription = "Slight rain showers"
        case 81:
            weatherDescription = "Moderate rain showers"
        case 82:
            weatherDescription = "Violent rain showers"
        case 85:
            weatherDescription = "Slight snow showers"
        case 86:
            weatherDescription = "Heavy snow showers"
        case 95:
            weatherDescription = "Slight or moderate thunderstorm"
        case 96:
            weatherDescription = "Thunderstorm with slight hail"
        case 99:
            weatherDescription = "Thunderstorm with heavy hail"
        default:
            weatherDescription = "Unknown weather condition"
        }
    return weatherDescription
}
