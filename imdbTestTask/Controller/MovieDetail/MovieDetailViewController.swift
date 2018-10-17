//
//  MovieDetailViewController.swift
//  imdbTestTask
//
//  Created by Nikita Kechinov on 16.10.2018.
//  Copyright © 2018 Nikita Kechinov. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var plot: UILabel!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var stars: UILabel!
    @IBOutlet weak var director: UILabel!
    @IBOutlet weak var country: UILabel!
    
    var posterImage: UIImage?
    var movieId: String?
    var observablePosterImage: UIImage? {
        didSet(value) {
            posterImage = value
            updatePoster()
        }
    }
    private var movieInfo: MovieInfo?
    
    //MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let id = movieId else { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        makeBackgroundVisible()
        
        NetworkManager.shared.getMovieInfo(with: id) { [weak self] (result) in
            switch result {
            case .success(let movieInfo):
                self?.updateUI(with: movieInfo)
                
            case .failure(let error):
                print(error)
                guard let currentVC = self else { return }
                ErrorManager.showErrorMessage(with: error, shownAt: currentVC)
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self?.hideBackground()
        }
    }
    
    //MARK: updating UI
    private func updatePoster() {
        guard let image = posterImage else { return }
        poster.image = image
    }
    
    private func makeBackgroundVisible() {
        //background.bringSubview(toFront: <#T##UIView#>)
        activityIndicator.startAnimating()
        background.backgroundColor = #colorLiteral(red: 0.1357881738, green: 0.1359588061, blue: 0.1329782852, alpha: 1)
    }
    
    private func hideBackground() {
        activityIndicator.stopAnimating()
        background.alpha = 0
    }
    
    private func updateUI(with movieInfo: MovieInfo) {
        movieTitle.text = movieInfo.title
        country.text = movieInfo.country
        rating.text = movieInfo.rating
        director.text = movieInfo.director
        stars.text = movieInfo.actors
        plot.text = movieInfo.plot
        guard let image = posterImage else { return }
        poster.image = image
    }
    
}
