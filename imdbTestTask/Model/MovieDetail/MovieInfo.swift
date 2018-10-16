//
//  MovieInfo.swift
//  imdbTestTask
//
//  Created by Nikita Kechinov on 16.10.2018.
//  Copyright © 2018 Nikita Kechinov. All rights reserved.
//

import Foundation


struct MovieInfo {
    let title: String
    let rating: String
    let country: String
    let director: String
    let actors: String
    let plot: String


}

extension MovieInfo: Decodable {
    private enum MovieInfoStructKeys: String, CodingKey {
        case title = "Title"
        case rating = "imdbRating"
        case country = "Country"
        case director = "Director"
        case actors = "Actors"
        case plot = "Plot"
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieInfoStructKeys.self)
        let title = try container.decode(String.self, forKey: .title)
        let rating = try container.decode(String.self, forKey: .rating)
        let country = try container.decode(String.self, forKey: .country)
        let director = try container.decode(String.self, forKey: .director)
        let actors = try container.decode(String.self, forKey: .actors)
        let plot = try container.decode(String.self, forKey: .plot)
        
        self.init(title: title, rating: rating, country: country, director: director, actors: actors, plot: plot)
    }
}

