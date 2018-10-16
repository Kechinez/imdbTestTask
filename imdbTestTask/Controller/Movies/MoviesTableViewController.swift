//
//  MoviesTableViewController.swift
//  imdbTestTask
//
//  Created by Nikita Kechinov on 15.10.2018.
//  Copyright © 2018 Nikita Kechinov. All rights reserved.
//

import UIKit

class MoviesTableViewController: UITableViewController, UISearchBarDelegate {

    var moviesList: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchBar()
        tableView.rowHeight = 90
        //tableView.estimatedRowHeight = 300
        
    }

    
    private func createSearchBar() {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.placeholder = "search the movies"
        navigationItem.titleView = searchBar
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
        cell.title.text = movie.title
        cell.genre.text = movie.year
        

        return cell
    }
    



}
