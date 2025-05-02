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
        performGETRequest(urlString: endpoint, key: .movieOverviewNP, completion: completed)
    }
    
    func getPopular(page: Int, completed: @escaping (Result<MovieResponse, AFError>) -> Void){
        let endpoint = "\(baseUrl)/movie/popular?language=en-US&page=\(page)"
        performGETRequest(urlString: endpoint, key: .movieOverviewPP, completion: completed)
    }
    
    func getUpcoming(page: Int, completed: @escaping (Result<MovieResponse, AFError>) -> Void){
        let endpoint = "\(baseUrl)/movie/upcoming?language=en-US&page=\(page)"
        performGETRequest(urlString: endpoint, key: .movieOverviewUP, completion: completed)
    }
    
    func getDetailMovie(id: Int, completed: @escaping (Result<MovieDetail, AFError>)-> Void){
        let endpoint = "\(baseUrl)/movie/\(id)?language=en-US"
        performGETRequest(urlString: endpoint, key: .movieDetail, completion: completed)
    }
}
