//
//  MovieResponse.swift
//  Trivinema
//
//  Created by Afif Fadillah on 26/04/25.
//

import Foundation

struct MovieResponse: Codable {
    let page: Int
    let results: [MoviewOverview]
    let totalPages: Int
    let totalResults: Int
}
