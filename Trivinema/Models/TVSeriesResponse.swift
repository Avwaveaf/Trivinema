//
//  MovieResponse.swift
//  Trivinema
//
//  Created by Afif Fadillah on 26/04/25.
//

import Foundation

struct TVSeriesResponse: Codable {
    let page: Int
    let results: [TVSeriesOverview]
    let totalPages: Int
    let totalResults: Int
}
