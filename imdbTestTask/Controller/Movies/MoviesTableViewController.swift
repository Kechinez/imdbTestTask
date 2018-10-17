//
//  MoviesTableViewController.swift
//  imdbTestTask
//
//  Created by Nikita Kechinov on 15.10.2018.
//  Copyright © 2018 Nikita Kechinov. All rights reserved.
//

import UIKit

class MoviesTableViewController: UITableViewController, UISearchBarDelegate {

    
    weak var observablePosterImage: UIImage?
    var moviesList: [Movie] = []
    var indexPathOfDownloadingCells: Set<IndexPath> = []
    var posterCache = NSCache<NSString, UIImage>()
    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchBar()
        //tableView.rowHeight = 94
        //tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 110
        //tableView.estimatedRowHeight = 300
        
    }

    
    private func createSearchBar() {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.placeholder = "search the movies"
        navigationItem.titleView = searchBar
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        NetworkManager.shared.getMoviesList(with: searchBar.text!) { [weak self] (moviesList) in
            switch moviesList {
            case .success(let tempMoviesList):
                print(tempMoviesList)
                self?.moviesList = tempMoviesList
                self?.tableView.reloadData()
            case .failure(let error):
                print(error)
                //guard let currentVC = self else { return }
                //ErrorManager.showErrorMessage(with: error, shownAt: currentVC)
            }
        }
        //searchBar.isFirstResponder = false
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MovieDetailsSegue" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let nextVC = segue.destination as? MovieDetailViewController else { return }
            let movie = moviesList[indexPath.row]
            
            nextVC.movieId = movie.id
            let key = NSString(string: movie.posterUrl)
            if let poster = posterCache.object(forKey: key) {
                nextVC.posterImage = poster
            } else {
                observablePosterImage = nextVC.observablePosterImage
            }
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return moviesList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCell
        let movie = moviesList[indexPath.row]
        
        if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows {
            let onScreenCellsIndexPath = Set(indexPathsForVisibleRows)
            let indexPathToBeCancelled = indexPathOfDownloadingCells.subtracting(onScreenCellsIndexPath)
            for indexPath in indexPathToBeCancelled {
                NetworkManager.shared.cancelDownloadingTaskForCellAt(indexPath)
            }
        }
        let key = NSString(string: movie.posterUrl)
        if let poster = posterCache.object(forKey: key) {
            cell.poster.image = poster
        } else {
            NetworkManager.shared.getPoster(with: movie.posterUrl, forCellAt: indexPath) {  [weak cell, weak self] (result) in
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else { return }
                    let key = NSString(string: movie.posterUrl)
                    self?.posterCache.setObject(image, forKey: key)
                    cell?.poster.image = image
                    self?.indexPathOfDownloadingCells.remove(indexPath)
                    
                    if tableView.indexPathForSelectedRow != nil {
                        self?.observablePosterImage = image
                    }
                    
                case .failure(let error):
                    print(error)
                    //guard let currentVC = self else { return }
                    //ErrorManager.showErrorMessage(with: error, shownAt: currentVC)
                }
            }
        }
        
        
        cell.title.text = movie.title
        cell.genre.text = movie.year
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    
    

}















