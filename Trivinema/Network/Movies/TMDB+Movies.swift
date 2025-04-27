//
//  TMDB+Movies.swift
//  Trivinema
//
//  Created by Afif Fadillah on 26/04/25.
//

import Foundation

extension NetworkManager {
    func getNowPlaying(page: Int, completed: @escaping (Result<MovieResponse, AFError>) -> Void){
        let endpoint = "\(baseUrl)/movie/now_playing?language=en-US&page=\(page)"
        performGETRequest(urlString: endpoint, key: .movieOverview, completion: completed)
    }
}
