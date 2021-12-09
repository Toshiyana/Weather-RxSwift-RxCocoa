//
//  ViewController.swift
//  WeatherApp-RxSwift-RxCocoa
//
//  Created by Toshiyana on 2021/12/09.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // One single request to api
        // .editingDidEndOnExit: When the keyboard goes away by pressing return key (<- end editing)
        cityNameTextField.rx.controlEvent(.editingDidEndOnExit)
            .asObservable()
            .map { self.cityNameTextField.text }
            .subscribe(onNext: { [weak self] city in

                if let city = city {
                    if city.isEmpty {
                        self?.displayWeather(nil)
                    } else {
                        self?.fetchWeather(by: city)
                    }
                }
            }).disposed(by: disposeBag)
        
        // Use the above code. (<- One single request)
        // Don't use the below code.(<- Too many request)
        // Request every time that textField.text was changed
//        cityNameTextField.rx.value
//            .subscribe(onNext: { [weak self] city in
//
//                if let city = city {
//                    if city.isEmpty {
//                        self?.displayWeather(nil)
//                    } else {
//                        self?.fetchWeather(by: city)
//                    }
//                }
//            }).disposed(by: disposeBag)
    }
    
    private func fetchWeather(by city: String) {
        // WeatherResult is representing root level of json including "main"
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let url = URL.urlForWeatherAPI(city: cityEncoded) else {
                  return
              }
        
        let resource = Resource<WeatherResult>(url: url)
        
        // Pattern 1 of binding way using driver
        // Including error handling
        let search = URLRequest.load(resource: resource) // search as an observable
            .observe(on: MainScheduler.instance)
            .retry(3) // Retry getting information by requesting url (in this case, retry 3 times. <- Don't retry infinite times for the performance)
            .catch { error in
                print(error.localizedDescription)
                return Observable.just(WeatherResult.empty)
            }.asDriver(onErrorJustReturn: WeatherResult.empty)
        
        // Not including error handling
//        let search = URLRequest.load(resource: resource) // search as an observable
//            .observe(on: MainScheduler.instance)
//            .asDriver(onErrorJustReturn: WeatherResult.empty)
        
        search.map { "\($0.main.temp) ℃" } // Producer
        .drive(temperatureLabel.rx.text) // Receiver
        .disposed(by: disposeBag)
        
        search.map { "\($0.main.humidity) 💦"} // Producer
        .drive(humidityLabel.rx.text) // Receiver
        .disposed(by: disposeBag)
        
        // Pattern 2 of binding way using bind
        // Display data using binding observables
//        let search = URLRequest.load(resource: resource) // search as an observable
//            .observe(on: MainScheduler.instance)
//            .catchAndReturn(WeatherResult.empty)
//
//        search.map { "\($0.main.temp) ℃" } // Producer
//        .bind(to: temperatureLabel.rx.text) // Receiver
//        .disposed(by: disposeBag)
//
//        search.map { "\($0.main.humidity) 💦"} // Producer
//        .bind(to: humidityLabel.rx.text) // Receiver
//        .disposed(by: disposeBag)
        
        // Pattern 3 of binding way (not simple)
//        URLRequest.load(resource: resource)
//            .observe(on: MainScheduler.instance) // To update UI, implement on main thread. (easier way than DispatchQueue.main.async {})
//            .catchAndReturn(WeatherResult.empty)
//            .subscribe(onNext: { [weak self] result in
//
//                print(result)
//
//                let weather = result.main
//                self?.displayWeather(weather)
//
//            }).disposed(by: disposeBag)
    }
    
    private func displayWeather(_ weather: Weather?) {
        
        if let weather = weather {
            temperatureLabel.text = "\(weather.temp) ℃"
            humidityLabel.text = "\(weather.humidity) 💦"
        } else {
            temperatureLabel.text = "🙈"
            humidityLabel.text = "∅"
        }
        
    }


}

