//
//  NetworkManager.swift
//  Trivinema
//
//  Created by Afif Fadillah on 25/04/25.
//

import UIKit

class NetworkManager {
    static let shared   = NetworkManager()
    let baseUrl = "https://api.themoviedb.org/3"
    let perPage = 100
    let cache           = NSCache<NSString, UIImage>()
    let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""

    private init() {}
    

    // MARK: - Generic GET Request Method

    func performGETRequest<T: Decodable>(urlString: String, completion: @escaping (Result<T, AFError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidResponse))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        #if DEBUG
        NetworkLogger.log(request: request)
        #endif

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            #if DEBUG
            NetworkLogger.log(response: response, data: data)
            #endif

            if let _ = error {
                completion(.failure(.noConnection))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            if let error = AFError.from(statusCode: httpResponse.statusCode) {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(.emptyDataOrJSON))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decoded = try decoder.decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(.failRequest))
            }
        }

        task.resume()
    }


}

enum AFError: String, Error{
    case invalidUserName = "This is username created an invalid request, please try again"
    case noConnection    = "Something went wrong! No internet connection"
    case invalidResponse = "Something went wrong! Invalid response from server"
    case emptyDataOrJSON = "Something went wrong! Empty data or invalid JSON format"
    case failRequest     = "Request failed, server returned an error. Please try again later."
    case failFav         = "Failed to add to favorite on this user, Please try again."
    case alreadyFav      = "Already added to favorite on this user."
    
    case badRequest      = "Bad request. Please check the input."
    case unauthorized    = "Unauthorized. Please login again."
    case forbidden       = "Forbidden. You don’t have permission to access this."
    case userNotFound    = "User not found. Please check the username."
    case tooManyRequests = "Too many requests. Please slow down."
    case serverError     = "Server error. Please try again later."
    case unhandledStatus = "Unhandled status code"
    case unknownError    = "Something went wrong. Please try again later."
}

extension AFError: LocalizedError {
    var errorDescription: String? {
        return self.rawValue
    }
    
    static func from(statusCode: Int) -> AFError? {
        switch statusCode {
        case 200:
            return nil
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .userNotFound
        case 429:
            return .tooManyRequests
        case 500...599:
            return .serverError
        default:
            #if DEBUG
            return .unhandledStatus
            #else
            return .unknownError
            #endif
        }
    }
}
