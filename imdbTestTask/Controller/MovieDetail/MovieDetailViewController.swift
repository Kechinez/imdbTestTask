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
        country.text = "Russia, USA, UK,Russia,USA,UK,Russia,USA,UK, Russia, USA, UK"//movieInfo.country
        rating.text = movieInfo.rating
        director.text = movieInfo.director
        stars.text = movieInfo.actors
        plot.text = "He was born Napoleone di Buonaparte (Italian: [napoleˈoːne di bwɔnaˈparte]) in Corsica to a relatively modest family of Italian origin from the minor nobility. He was serving as an artillery officer in the French army when the French Revolution erupted in 1789. He rapidly rose through the ranks of the military, seizing the new opportunities presented by the Revolution and becoming a general at age 24. The French Directory eventually gave him command of the Army of Italy after he suppressed a revolt against the government from royalist insurgents. At age 26, he began his first military campaign against the Austrians and their Italian allies—winning virtually every battle, conquering the Italian Peninsula in a year, and becoming a war hero in France. In 1798, he led a military expedition to Egypt that served as a springboard to political power. He orchestrated a coup in November 1799 and became First Consul of the Republic. His ambition and public approval inspired him to go further, and he became the first Emperor of the French in 1804. Intractable differences with the British meant that the French were facing a Third Coalition by 1805. Napoleon shattered this coalition with decisive victories in the Ulm Campaign and a historic triumph over the Russian Empire and Austrian Empire at the Battle of Austerlitz which led to the Dissolution of the Holy Roman Empire. In 1806, the Fourth Coalition took up arms against him because Prussia became worried about growing French influence on the continent. Napoleon quickly defeated Prussia at the battles of Jena and Auerstedt, then marched his Grande Armée deep into Eastern Europe and annihilated the Russians in June 1807 at the Battle of Friedland. France then forced the defeated nations of the Fourth Coalition to sign the Treaties of Tilsit in July 1807, bringing an uneasy peace to the continent. Tilsit signified the high-water mark of the French Empire. In 1809, the Austrians and the British challenged the French again during the War of the Fifth Coalition, but Napoleon solidified his grip over Europe after triumphing at the Battle of Wagram in July."//movieInfo.plot
        guard let image = posterImage else { return }
        poster.image = image
        
    }
    

}
