//
//  NetworkManager.swift
//  Trivinema
//
//  Created by Afif Fadillah on 25/04/25.
//

import UIKit

enum OverviewKey: String{
    case movieOverviewNP        = "moviewOverviewNP"
    case movieOverviewPP        = "moviewOverviewPP"
    case movieOverviewUP        = "moviewOverviewUP"
    case movieDetail            = "movieDetail"
    case tvSeriesOverviewPP     = "tvSeriesOverviewPP"
    case tvSeriesOverviewAT     = "tvSeriesOverviewAT"
    case tvSeriesOverviewTR     = "tvSeriesOverviewTR"
    case tvSeriesDetail         = "tvSeriesDetail"
    case artistsOverview        = "artistsOverview"
    case artistsDetail          = "artistsDetail"
    case movieVideo             = "movieVideo"
    case seriesVideo            = "seriesVideo"
}

class NetworkManager {
    static let shared  = NetworkManager()
    let baseUrl        = "https://api.themoviedb.org/3"
    let perPage        = 100
    let cache          = NSCache<NSString, UIImage>()
    let apiKey         = Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""
    
    private init() {}
    
    
    // MARK: - Generic GET Request Method
    
    func performGETRequest<T: Codable>(urlString: String, key: OverviewKey, completion: @escaping (Result<T, AFError>) -> Void) {
        DispatchQueue.global(qos: .background).async{
            // MARK: -Ceheck stale cache-
            if self.isNewDay(for: key){
                self.clearCache(for: key)
            }
            
            // MARK: -Handle cache [RETRIEVE]-
            if let cachedData: T = self.getCachedOverviewFromDisk(for: urlString) {
                /// uncomment Debug
                //print("using cache for key \(key.rawValue)")
                completion(.success(cachedData))
                return
            }
            
            guard let url = URL(string: urlString) else {
                completion(.failure(.invalidResponse))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.apiKey)", forHTTPHeaderField: "Authorization")
            
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
                    
                    // MARK: -Handle Cache [SAVE]-
                    self.cacheOverviewToDisk(for: key.rawValue, overviewData: decoded)
                    
                    completion(.success(decoded))
                } catch {
                    completion(.failure(.failRequest))
                }
            }
            
            task.resume()
        }
    }
    
    
}

/// This network manager act to store on disk caching
extension NetworkManager{
    
    // Cache: Save
    func cacheOverviewToDisk<T: Codable>(for key: String, overviewData: T){
        let encoder = JSONEncoder()
        do {
            let data    = try encoder.encode(overviewData)
            let fileURL = getCacheFileURL(for: key)
            try data.write(to: fileURL)
        } catch {
            print("Failed to cache data in \(key): \(error.localizedDescription)")
        }
    }
    
    // Cache: Retrieve
    func getCachedOverviewFromDisk<T: Decodable>(for key: String) -> T? {
        let fileURL     = getCacheFileURL(for: key)
        guard let data  = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            let overview = try decoder.decode(T.self, from: data)
            return overview
        } catch {
            print("Failed to decode overview in \(key): \(error.localizedDescription)")
        }
        
        return nil
    }
    
    // MARK: -Cache Helper-
    
    // Helper: stale cache checker
    private func isNewDay(for key: OverviewKey) -> Bool {
        let lastCacheDateKey = "\(key.rawValue)_cache_date"
        
        if let lastCacheDate = UserDefaults.standard.value(forKey: lastCacheDateKey) as? Date{
            let calendar = Calendar.current
            return !calendar.isDateInToday(lastCacheDate)
        }
        
        return true
    }
    
    // Helper: get cache directory
    private func getCacheDirectory() -> URL {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        return cacheDirectory
    }
    
    // Helper: get cache URL for key
    private func getCacheFileURL(for key: String, isImage: Bool = false) -> URL{
        let cacheDirectory = self.getCacheDirectory()
        let fileExt        = isImage ? "" : "json"
        return cacheDirectory.appendingPathComponent("\(key).\(fileExt)")
    }
    
    // Helper: clear cache
    private func clearCache(for key: OverviewKey) {
        let jsonFileURL = getCacheFileURL(for: key.rawValue)
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: jsonFileURL.path) {
            do {
                try fileManager.removeItem(at: jsonFileURL)
            } catch {
                print("Failed to clear cache for \(key.rawValue): \(error.localizedDescription)")
            }
        } else {
            print("Cache file for \(key.rawValue) does not exist. No need to remove.")
        }
        
        UserDefaults.standard.setValue(Date(), forKey: "\(key.rawValue)_cache_date")
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
