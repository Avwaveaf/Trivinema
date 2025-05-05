//
//  CastResponse.swift
//  Trivinema
//
//  Created by Afif Fadillah on 02/05/25.
//

import Foundation

struct CastResponse: Codable{
    let id   : Int
    let cast : [ArtistsOverview]
}

struct CastPersonResponse: Codable {
    let cast : [CastCredit]
}


struct CastCredit: Codable, Hashable {
    let id: Int
    let title: String
    let originalTitle: String
    let character: String
    let posterPath: String?
    let backdropPath: String?
    let genreIds: [Int]
    let overview: String
    let popularity: Double
    let voteAverage: Double
    let creditId: String
    let order: Int
    let mediaType: String
}
