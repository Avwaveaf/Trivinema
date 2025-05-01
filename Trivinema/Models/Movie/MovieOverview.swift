//
//  MovieOverview.swift
//  Trivinema
//
//  Created by Afif Fadillah on 25/04/25.
//

import Foundation

struct MoviewOverview: Codable, Hashable, OverviewPresentable{
    var categoryString: String {
        self.genreIds.map {
            MovieGenre.from(id: $0)
        }.joined(separator: " ・ ")
    }
    
    let adult: Bool
    let backdropPath: String?
    let genreIds: [Int]
    let id: Int
    let originalTitle: String
    let title: String
    let overview: String
    let popularity: Double
    let posterPath: String?
    let voteAverage: Double
}
