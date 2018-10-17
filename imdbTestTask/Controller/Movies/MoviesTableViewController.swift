//
//  MoviesTableViewController.swift
//  imdbTestTask
//
//  Created by Nikita Kechinov on 15.10.2018.
//  Copyright © 2018 Nikita Kechinov. All rights reserved.
//

import UIKit

class MoviesTableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    weak var observablePosterImage: UIImage?
    private var moviesList: [Movie] = []
    private var indexPathOfDownloadingCells: Set<IndexPath> = []
    private var posterCache = NSCache<NSString, UIImage>()
    private var didTapDeleteKey = false
    //MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchBar()
        tableView.rowHeight = CGFloat.calculateCellHeight(accordingTo: view.frame.width)
    }

    //MARK: - Segue methods
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
    
    //MARK: - Supporting methods
    private func createSearchBar() {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.placeholder = "search the movies"
        navigationItem.titleView = searchBar
    }
    
    private func cleanTableView() {
        moviesList.removeAll()
        tableView.reloadData()
    }
    
    //MARK: - Networking
    private func getPoster(with id: String, forCellAt indexPath: IndexPath) {
        NetworkManager.shared.getPoster(with: id, forCellAt: indexPath) {  [weak self] (result) in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                let key = NSString(string: id)
                self?.posterCache.setObject(image, forKey: key)
                self?.indexPathOfDownloadingCells.remove(indexPath)
                guard let currentCell = self?.tableView.cellForRow(at: indexPath) as? MovieCell else { return }
                currentCell.poster.image = image
                
                if self?.tableView.indexPathForSelectedRow != nil {
                    self?.observablePosterImage = image
                }
                
            case .failure(let error):
                print(error)
                guard let currentVC = self else { return }
                ErrorManager.showErrorMessage(with: error, shownAt: currentVC)
            }
        }
    }
    
    private func getMovies(at keyword: String) {
        NetworkManager.shared.getMoviesList(with: keyword) { [weak self] (moviesList) in
            switch moviesList {
            case .success(let tempMoviesList):
                self?.moviesList = tempMoviesList
                self?.tableView.reloadData()
            case .failure(let error):
                guard let currentVC = self else { return }
                ErrorManager.showErrorMessage(with: error, shownAt: currentVC)
            }
        }
    }
    
}

//MARK: TableViewController Delegate and DataSourse
extension MoviesTableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            getPoster(with: movie.posterUrl, forCellAt: indexPath)
        }
        
        cell.title.text = movie.title
        cell.genre.text = movie.year
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UISearchBar Delegate
extension MoviesTableViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        didTapDeleteKey = text.isEmpty
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !didTapDeleteKey && searchText.isEmpty {
            cleanTableView()
        }
        didTapDeleteKey = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text else { return }
        getMovies(at: keyword)
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

