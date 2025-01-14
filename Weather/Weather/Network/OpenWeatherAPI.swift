//
//  OpenWeatherAPI.swift
//  Weather
//
//  Created by Denidu Gamage on 2024-12-29.
//

import Foundation
import Alamofire

class OpenweatherAPI {
    typealias WeatherCompletionHandler = (WeatherDataModel?, Error?) -> Void
    typealias GeoCompletionHandler = (GeoDataModel?, Error?) -> Void
    
    private var apiKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenWeatherAPIKey") as? String else {
            fatalError("API Key not found in Info.plist")
        }
        return apiKey
    }
    
    private func createWeatherURL(lat: Double, lon: Double) -> String {
        let baseURL = "https://api.openweathermap.org/data/3.0/onecall"
        let url = "\(baseURL)?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)"
        
        return url
    }
    
    private func createGeoURL(city: String, state: String? = nil, country: String? = nil, limit: Int = 1) -> String {
        var components = ["https://api.openweathermap.org/geo/1.0/direct?q=\(city)"]
        
        if let state = state, !state.isEmpty {
            components.append(state)
        }
        if let country = country, !country.isEmpty {
            components.append(country)
        }
        
        let query = components.joined(separator: ",")
        return "\(query)&limit=\(limit)&appid=\(apiKey)"
    }
    
    func fetchWeather(lat: Double, lon: Double, completion: @escaping WeatherCompletionHandler) {
        let url = createWeatherURL(lat: lat, lon: lon)
        
        AF.request(url).validate().responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decodedData = try JSONDecoder().decode(WeatherDataModel.self, from: data)
                    completion(decodedData, nil)
                } catch let decodingError {
                    completion(nil, decodingError)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func fetchCoordinates(city: String, state: String, country: String, limit: Int = 5, completion: @escaping GeoCompletionHandler) {
        let url = createGeoURL(city: city, state: state, country: country, limit: limit)
        
        AF.request(url).validate().responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decodedData = try JSONDecoder().decode([GeoDataModel].self, from: data)
                    completion(decodedData.first, nil)
                } catch let decodingError {
                    completion(nil, decodingError)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
