//
//  CityView.swift
//  Weather
//
//  Created by Denidu Gamage on 2025-01-02.
//

import SwiftUI

struct CityView: View {
    var cityName: String
    var weatherData: WeatherDataModel?
    @AppStorage("userLocationInput") private var userLocationInput: String = ""
    @AppStorage("favoriteCities") private var favoriteCities: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var weatherViewModel = WeatherViewModel()
    
    @State private var isLoading: Bool = true
    
    private var isFavorite: Bool {
        favoriteCities.split(separator: ",").contains(where: { $0.trimmingCharacters(in: .whitespaces) == cityName })
    }
    
    private func switchFav() {
        var updatedFavorites = Set(favoriteCities.split(separator: ",").map { String($0) })
        
        if isFavorite {
            updatedFavorites.remove(cityName)
        } else {
            updatedFavorites.insert(cityName)
        }
        
        favoriteCities = updatedFavorites.joined(separator: ",")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Spacer().frame(height: 40)
                    
                    if isLoading {
                        ProgressView("Loading weather data...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    } else if let weatherData = weatherViewModel.weatherDataModel {
                        VStack(alignment: .center) {
                            HStack {
                                
                                Spacer()
                                
                                Text(cityName)
                                    .font(.system(size: 36, weight: .medium))
                                    .padding(.leading)
                                
                                Spacer()
                                
                                Button(action: {
                                    switchFav()
                                }) {
                                    Image(systemName: isFavorite ? "star.fill" : "star")
                                        .foregroundColor(.blue)
                                        .font(.title)
                                        .padding(.trailing)
                                }
                            }
                            
                            Text("\(Int(weatherData.current.temp))°")
                                .font(.system(size: 94, weight: .thin))
                            
                            Text(weatherData.current.weather.first?.description.capitalized ?? "")
                                .font(.title3)
                            
                            Text("H:\(Int(weatherData.daily[0].temp.max))° L:\(Int(weatherData.daily[0].temp.min))°")
                                .font(.title3)
                        }
                        
                        // Hourly forecast
                        VStack(alignment: .leading, spacing: 20) {
                            Text("HOURLY FORECAST")
                                .font(.caption)
                                .padding(.top)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(weatherData.hourly.prefix(6), id: \.dt) { hour in
                                        VStack {
                                            let formattedDate = DateFormatterUtils.formattedDate12Hour(from: TimeInterval(hour.dt))
                                            Text(formattedDate)
                                            
                                            let iconName = hour.weather.first?.icon ?? "default-icon"
                                            let iconUrl = "http://openweathermap.org/img/wn/\(iconName)@2x.png"
                                            
                                            AsyncImage(url: URL(string: iconUrl)) { image in
                                                image.resizable()
                                                    .scaledToFit()
                                                    .frame(width: 50, height: 50)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            
                                            Text("\(Int(hour.temp))°")
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.horizontal)
                        
                        // 10-day forecast
                        VStack(alignment: .leading, spacing: 15) {
                            Text("10-DAY FORECAST")
                                .font(.caption)
                                .padding(.top)
                            
                            ForEach(weatherData.daily.prefix(6), id: \.dt) { day in
                                HStack {
                                    let formattedDate = DateFormatterUtils.formattedDateWithWeekdayAndDay(from: TimeInterval(day.dt))
                                    Text(formattedDate)
                                        .padding(.leading)
                                    
                                    Spacer()
                                    
                                    let iconName = day.weather.first?.icon ?? "default-icon"
                                    let iconUrl = "http://openweathermap.org/img/wn/\(iconName)@2x.png"
                                    
                                    AsyncImage(url: URL(string: iconUrl)) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    
                                    Text("\(Int(day.temp.min))°")
                                        .frame(width: 30, alignment: .trailing)
                                    
                                    TempBarView(tempMin: day.temp.min, tempMax: day.temp.max)
                                        .frame(width: 100)
                                    
                                    Text("\(Int(day.temp.max))°")
                                        .frame(width: 30, alignment: .trailing)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                    } else {
                        Text("No weather data available.")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 20)
                .onAppear {
                    Task {
                        isLoading = true
                        do {
                            try await weatherViewModel.fetchGeoData(city: cityName, state: "", country: "")
                            isLoading = false
                        } catch {
                            isLoading = false
                        }
                    }
                }
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4),
                                                                   Color.purple.opacity(0.4)]),
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.4)]),
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    CityView(cityName: "", weatherData: nil)
}
