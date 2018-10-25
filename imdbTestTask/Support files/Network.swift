//
//  Network.swift
//  imdbTestTask
//
//  Created by Nikita Kechinov on 15.10.2018.
//  Copyright © 2018 Nikita Kechinov. All rights reserved.
//

import Foundation

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
    private init() {}
    private let session = URLSession(configuration: .default)
    private var runningDownloadingTasks: [String: URLSessionDataTask] = [:]
    
    //MARK: - Downloading
    func getMoviesList(with searchTitle: String, completionHandler: @escaping ((APIResult<[Movie]>) -> ())) {
        guard let request = ApiRequests.getMoviesList(searchTitle).request else { return }
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil && data != nil else {
                self.returnHandlerOnMainQueue(with: .failure(error!), handler: completionHandler)
                return
            }
            
            let responseChecked = self.isResponseValid(response: response)
            guard responseChecked.bool else {
                self.returnHandlerOnMainQueue(with: .failure(responseChecked.error!), handler: completionHandler)
                return
            }
            
            do {
                let movieList = try JSONDecoder().decode(Search.self, from: data!)
                self.returnHandlerOnMainQueue(with: .success(movieList.result), handler: completionHandler)
                return
            } catch let error {
                self.returnHandlerOnMainQueue(with: .failure(error), handler: completionHandler)
                return
            }
        }
        dataTask.resume()
    }
    
    func getPoster(with posterUrl: String, forCellAt indexPath: IndexPath, completionHandler: @escaping ((APIResult<Data>) -> ())) {
        guard let url = URL(string: posterUrl) else { return }
        let request = URLRequest(url: url)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil && data != nil else {
                self.returnHandlerOnMainQueue(with: .failure(error!), handler: completionHandler)
                return
            }
            
            let responseChecked = self.isResponseValid(response: response)
            guard responseChecked.bool else {
                self.returnHandlerOnMainQueue(with: .failure(responseChecked.error!), handler: completionHandler)
                return
            }
            
            let key = String(indexPath.row)
            self.runningDownloadingTasks.removeValue(forKey: key)
            self.returnHandlerOnMainQueue(with: .success(data!), handler: completionHandler)
        }
        dataTask.resume()
        let key = String(indexPath.row)
        runningDownloadingTasks[key] = dataTask
    }
    
    func getMovieInfo(with movieId: String, completionHandler: @escaping ((APIResult<MovieInfo>) -> ())) {
        guard let request = ApiRequests.getMovie(movieId).request else { return }
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil && data != nil else {
                self.returnHandlerOnMainQueue(with: .failure(error!), handler: completionHandler)
                return
            }
            
            let responseChecked = self.isResponseValid(response: response)
            guard responseChecked.bool else {
                self.returnHandlerOnMainQueue(with: .failure(responseChecked.error!), handler: completionHandler)
                return
            }
            
            do {
                let movieInfo = try JSONDecoder().decode(MovieInfo.self, from: data!)
                self.returnHandlerOnMainQueue(with: .success(movieInfo), handler: completionHandler)
                return
            } catch let error {
                self.returnHandlerOnMainQueue(with: .failure(error), handler: completionHandler)
                return
            }
            
        }
        dataTask.resume()
    }
    
    //MARK: Supporting methods
    private func returnHandlerOnMainQueue<T>(with result: APIResult<T>, handler: @escaping ((APIResult<T>) -> ())) {
        DispatchQueue.main.async {
            handler(result)
        }
    }
    
    func cancelDownloadingTaskForCellAt(_ indexPath: IndexPath) {
        let key = String(indexPath.row)
        guard let taskToBeCancelled = runningDownloadingTasks.removeValue(forKey: key) else { return }
        taskToBeCancelled.cancel()
    }
    
    private func isResponseValid(response: URLResponse?) -> (bool: Bool, error: Error?) {
        guard let httpResponse = response as? HTTPURLResponse else {
            let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Server replied with invalid protocol!", comment: "")]
            let httpError = NSError(domain: "errorDomain", code: 100, userInfo: userInfo)
            return (false, httpError)
        }
        switch httpResponse.statusCode {
        case 200:
            return (true, nil)
        default:
            let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Requested resource could not be found!", comment: "")]
            let httpError = NSError(domain: "errorDomain", code: 100, userInfo: userInfo)
            return (false, httpError)
        }
    }
    
}
//MARK: - protocols

protocol NetworkProtocol {
    func getDatabase(with id: String) -> [String: Any]
    func getEntity(with raw: String) -> String
}

protocol NetworkChecking {
    func isNetworkExist() -> Bool
    func didHaveError(with id: String) -> Bool
}

protocol TestingProtocol {
    func zdrastitya()
}


//MARK: - NewClass

class testClass {
    let e = "@@"
    let a = 34
    
    func testFunc() {
        print("Hello World!")
    }
    func showE() {
        print(e)
    }
    
}

class AnotherClasJustForTesting {
    let t = 5
    let y = 12233
    let w = "wweerr"
}
