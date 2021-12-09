//
//  WeatherResult.swift
//  WeatherApp-RxSwift-RxCocoa
//
//  Created by Toshiyana on 2021/12/09.
//

import Foundation

struct WeatherResult: Decodable {
    let main: Weather // json key of open weather api
}

extension WeatherResult {
    static var empty: WeatherResult {
        return WeatherResult(main: Weather(temp: 0.0, humidity: 0.0))
    }
}

struct Weather: Decodable {
    let temp: Double
    let humidity: Double
}
