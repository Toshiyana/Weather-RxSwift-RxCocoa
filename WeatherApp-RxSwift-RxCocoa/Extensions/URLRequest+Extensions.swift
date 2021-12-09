//
//  URLRequest+Extensions.swift
//  WeatherApp-RxSwift-RxCocoa
//
//  Created by Toshiyana on 2021/12/09.
//

import Foundation
import RxSwift
import RxCocoa

struct Resource<T> {
    let url: URL
}

extension URLRequest {

    // Including error handling by checking status code
    static func load<T: Decodable>(resource: Resource<T>) -> Observable<T> {
        
        return Observable.just(resource.url)
            .flatMap { url -> Observable<(response: HTTPURLResponse, data: Data)> in
                let request = URLRequest(url: url)
                return URLSession.shared.rx.response(request: request)
            }.map { response, data -> T in
                
                if 200..<300 ~= response.statusCode {
                    return try JSONDecoder().decode(T.self, from: data)
                } else {
                    // Throw Error
                    throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
                }
            }
    }
    
    // Not indluding error handling
//    static func load<T: Decodable>(resource: Resource<T>) -> Observable<T> {
//
//        return Observable.from([resource.url])
//            .flatMap { url -> Observable<Data> in
//                let request = URLRequest(url: url)
//                return URLSession.shared.rx.data(request: request)
//            }.map { data -> T in
//                return try JSONDecoder().decode(T.self, from: data)
//            }.asObservable()
//    }
    
}
