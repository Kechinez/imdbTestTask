//
//  MovieDetailViewController.swift
//  imdbTestTask
//
//  Created by Nikita Kechinov on 16.10.2018.
//  Copyright © 2018 Nikita Kechinov. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
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
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        NotificationCenter.default.addObserver(self, selector: #selector(updatePoster(with:)), name: Notification.Name.PosterDownloadCompleted, object: nil)
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    private func updatePoster() {
        guard let image = posterImage else { return }
        poster.image = image
    }
    
    
    
    func updatingPoster(with image: UIImage) {
        poster.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let id = movieId else { return }
        NetworkManager.shared.getMovieInfo(with: id) { [weak self] (result) in
            switch result {
            case .success(let movieInfo):
                self?.updateUI(with: movieInfo)
            case .failure(let error):
                print(error)
                //guard let currentVC = self else { return }
                //ErrorManager.showErrorMessage(with: error, shownAt: currentVC)
            }
        }
        
        
        
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