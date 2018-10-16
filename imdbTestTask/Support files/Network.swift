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
    //http://www.omdbapi.com/?apikey=4a8f0e16&t&s=titanic
    //tt0120338
    //http://www.omdbapi.com/?apikey=4a8f0e16&t&i=tt0120338
    private var baseURL: URL? {
        let urlString = String("http://www.omdbapi.com/")
        return URL(string: urlString)
    }
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
    private var runningDownloadingTasks: [String: URLSessionDataTask] = [:]
    
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
    
    func getPoster(with posterUrl: String, forCellAt indexPath: IndexPath, completionHandler: @escaping ((APIResult<Data>) -> ())) {
        guard let url = URL(string: posterUrl) else { return }
        let request = URLRequest(url: url)
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
                let key = String(indexPath.row)
                self?.runningDownloadingTasks.removeValue(forKey: key)
                self?.returnHandlerOnMainQueue(with: .success(data!), handler: completionHandler)
            default:
                let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Requested resource could not be found!", comment: "")]
                let error = NSError(domain: "errorDomain", code: 100, userInfo: userInfo)
                self?.returnHandlerOnMainQueue(with: .failure(error), handler: completionHandler)
                return
            }
        }
        dataTask.resume()
        let key = String(indexPath.row)
        runningDownloadingTasks[key] = dataTask
    }
    
    func getMovieInfo(with movieId: String, completionHandler: @escaping ((APIResult<MovieInfo>) -> ())) {
        guard let request = ApiRequests.getMovie(movieId).request else { return }
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
                    let movieInfo = try JSONDecoder().decode(MovieInfo.self, from: data!)
                    self?.returnHandlerOnMainQueue(with: .success(movieInfo), handler: completionHandler)
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
    
    func cancelDownloadingTaskForCellAt(_ indexPath: IndexPath) {
        let key = String(indexPath.row)
        guard let taskToBeCancelled = runningDownloadingTasks.removeValue(forKey: key) else { return }
        taskToBeCancelled.cancel()
    }
            
    
    
}
