//
//  URL+Extensions.swift
//  WeatherApp-RxSwift-RxCocoa
//
//  Created by Toshiyana on 2021/12/09.
//

import Foundation

extension URL {
    
    static func urlForWeatherAPI(city: String) -> URL? {
        // two kinds of units
        // units=metric (Celsius)
        // units=imperial (Fahrenheit)
        return URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(T.weatherAPIKey)&units=metric")
    }
    
}
