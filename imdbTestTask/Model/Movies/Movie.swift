//
//  Movie.swift
//  imdbTestTask
//
//  Created by Nikita Kechinov on 15.10.2018.
//  Copyright © 2018 Nikita Kechinov. All rights reserved.
//

import Foundation

struct Movie {
    let title: String
    let year: String
    let posterUrl: String
    let id: String
}

struct Search {
    let result: [Movie]
}

//MARK: - Search's Decodable implementation
extension Search: Decodable {
    private enum SearchStructKeys: String, CodingKey {
        case result = "Search"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SearchStructKeys.self)
        let result = try container.decode([Movie].self, forKey: .result)
        self.init(result: result)
    }
}

//MARK: - Movie's Decodable implementation
extension Movie: Decodable {
    private enum MovieStructKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case posterUrl = "Poster"
        case id = "imdbID"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieStructKeys.self)
        let title = try container.decode(String.self, forKey: .title)
        let year = try container.decode(String.self, forKey: .year)
        let posterUrl = try container.decode(String.self, forKey: .posterUrl)
        let id = try container.decode(String.self, forKey: .id)

        self.init(title: title, year: year, posterUrl: posterUrl, id: id)
    }
}
