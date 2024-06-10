//
//  MovieModel.swift
//  movie
//
//  Created by oscar perdana on 07/06/24.
//

import Foundation

struct Movie: Identifiable, Decodable {
    let id = UUID()
    let Title: String
    let Year: String
    let imdbID: String
    let Poster: String
    
    private enum CodingKeys: String, CodingKey {
        case Title, Year, imdbID, Poster
    }
}

struct MovieResponse: Decodable {
    let Search: [Movie]
}

struct MovieDetail: Decodable {
    let Title: String
    let Year: String
    let Rated: String
    let Released: String
    let Runtime: String
    let Genre: String
    let Director: String
    let Writer: String
    let Actors: String
    let Plot: String
    let Language: String
    let Country: String
    let Awards: String
    let Poster: String
    let Ratings: [Rating]
    let Metascore: String
    let imdbRating: String
    let imdbVotes: String
    let imdbID: String
    let MediaType: String?
    let DVD: String
    let BoxOffice: String
    let Production: String
    let Website: String
    
    struct Rating: Decodable {
        let Source: String
        let Value: String
    }
}
