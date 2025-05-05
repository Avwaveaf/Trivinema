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

struct CastPersonResponseMovie: Codable {
    let id   : Int
    let cast : [MoviewOverview]
}

struct CastPersonResponseTv: Codable {
    let id   : Int
    let cast : [TVSeriesOverview]
}
