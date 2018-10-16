//
//  Network.swift
//  imdbTestTask
//
//  Created by Nikita Kechinov on 15.10.2018.
//  Copyright © 2018 Nikita Kechinov. All rights reserved.
//

import Foundation
public typealias JSON = [String: Any]


public enum APIResult<T> {
    case success(T)
    case failure(Error)
}

//MARK: - Building API request
private enum ApiRequests {
    case getMoviesList(String)
    case getMovie(String)
    
    private var baseURL: URL? {
        let urlString = String("http://www.omdbapi.com/")
        return URL(string: urlString)
    }
    //http://www.omdbapi.com/?apikey=4a8f0e16&t=tt0115392
    private var apiKey: String {
        return "?apikey=4a8f0e16&t&"
    }
    private var path: String {
        switch self {
        case .getMovie(let id):
            return apiKey + String("i=") + id
        case .getMoviesList(let searchTitle):
            return apiKey + String("s=") + searchTitle
        }
    }
    var request: URLRequest? {
        switch self {
        case .getMovie:
            guard let url = URL(string: path, relativeTo: baseURL) else { return nil }
            return URLRequest(url: url)
        case .getMoviesList:
            guard let url = URL(string: path, relativeTo: baseURL) else { return nil }
            return URLRequest(url: url)
        }
    }
}


//MARK: Network manager
final class NetworkManager {
    static let shared = NetworkManager()
    
    init() {}
    
    private let session = URLSession(configuration: .default)
    private var getRouteTask: URLSessionTask?
    
    
    private func returnHandlerOnMainQueue<T>(with result: APIResult<T>, handler: @escaping ((APIResult<T>) -> ())) {
        DispatchQueue.main.async {
            handler(result)
        }
    }
    
    func getMoviesList(with searchTitle: String, completionHandler: @escaping ((APIResult<[Movie]>) -> ())) {
        guard let request = ApiRequests.getMoviesList(searchTitle).request else { return }
        
        print(request.url!)
        
        let dataTask = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Server replied with invalid protocol!", comment: "")]
                let httpError = NSError(domain: "errorDomain", code: 100, userInfo: userInfo)
                self?.returnHandlerOnMainQueue(with: .failure(httpError), handler: completionHandler)
                return
            }
            guard error == nil && data != nil else {
                self?.returnHandlerOnMainQueue(with: .failure(error!), handler: completionHandler)
                return
            }
            switch httpResponse.statusCode {
            case 200:
                do {
                    let movieList = try JSONDecoder().decode(Search.self, from: data!)
                    self?.returnHandlerOnMainQueue(with: .success(movieList.result), handler: completionHandler)
                    return
                } catch let error {
                    self?.returnHandlerOnMainQueue(with: .failure(error), handler: completionHandler)
                    return
                }
            default:
                let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Requested resource could not be found!", comment: "")]
                let error = NSError(domain: "errorDomain", code: 100, userInfo: userInfo)
                self?.returnHandlerOnMainQueue(with: .failure(error), handler: completionHandler)
                return
            }
        }
        dataTask.resume()
    }
    
            
            
    
    
    
    
//
//    func getRoute(with startCoordinate: CLLocationCoordinate2D, and finishCoordinate: CLLocationCoordinate2D, completionHandler: @escaping (APIResult<Route>) -> ()) {
//
//        getRouteTask?.cancel()
//
//
//        let dataTask = session.dataTask(with: request) { [weak self] (data, response, error) in
//
//
//
//
//
//
//            if let error = error {
//                self?.returnHandlerOnMainQueue(with: .failure(error), handler: completionHandler)
//                return
//            }
//            do {
//                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! JSON
//                guard let routeInfo = Route(data: json)  else { return }
//                self?.returnHandlerOnMainQueue(with: .success(routeInfo), handler: completionHandler)
//
//            } catch {
//                print("can't convert to JSON object!")
//            }
//        }
//        getRouteTask = dataTask
//        dataTask.resume()
//
//    }
    
    
//    func getCars(completionHandler: @escaping ((APIResult<[Car]>) -> ())) {
//
//        guard let request = ApiRequests.getCars.request else { return }
//
//        session.dataTask(with: request) {  [weak self] (data, response, error) in
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Server replied with invalid protocol!", comment: "")]
//                let httpError = NSError(domain: "errorDomain", code: 100, userInfo: userInfo)
//                self?.returnHandlerOnMainQueue(with: .failure(httpError), handler: completionHandler)
//                return
//            }
//            guard error == nil && data != nil else {
//                self?.returnHandlerOnMainQueue(with: .failure(error!), handler: completionHandler)
//                return
//            }
//            switch httpResponse.statusCode {
//            case 200:
//                do {
//                    let carsData = try JSONDecoder().decode(Locations.self, from: data!)
//                    self?.returnHandlerOnMainQueue(with: .success(carsData.placemarks), handler: completionHandler)
//                    return
//                } catch let error {
//                    self?.returnHandlerOnMainQueue(with: .failure(error), handler: completionHandler)
//                    return
//                }
//
//            default:
//                let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Requested resource could not be found!", comment: "")]
//                let error = NSError(domain: "errorDomain", code: 100, userInfo: userInfo)
//                self?.returnHandlerOnMainQueue(with: .failure(error), handler: completionHandler)
//                return
//            }
//            }.resume()
//    }
    
    
}
