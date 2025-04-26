//
//  NetworkLogger.swift
//  Trivinema
//
//  Created by Afif Fadillah on 25/04/25.
//


import Foundation

class NetworkLogger {
    
    static func log(request: URLRequest) {
        print("\n🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵 REQUEST 🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵")
        
        print("🌐 URL: \(request.url?.absoluteString ?? "No URL")")
        print("📬 METHOD: \(request.httpMethod ?? "No method")")
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("🧾 HEADERS:")
            for (key, value) in headers {
                print("   - \(key): \(value)")
            }
        } else {
            print("🧾 HEADERS: None")
        }

        if let body = request.httpBody,
           let json = try? JSONSerialization.jsonObject(with: body, options: .fragmentsAllowed),
           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("📝 BODY:\n\(prettyString)")
        } else {
            print("📝 BODY: Empty or Not JSON")
        }
        
        print("🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵\n")
    }
    
    static func log(response: URLResponse?, data: Data?) {
        print("\n🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢 RESPONSE 🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢")

        guard let httpResponse = response as? HTTPURLResponse else {
            print("⛔️ Invalid or nil HTTPURLResponse")
            return
        }
        
        print("📦 STATUS CODE: \(httpResponse.statusCode)")
        
        if let data = data,
           let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed),
           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("📨 BODY:\n\(prettyString)")
        } else if let data = data,
                  let plainString = String(data: data, encoding: .utf8) {
            print("📨 BODY (Plain Text):\n\(plainString)")
        } else {
            print("📨 BODY: Empty or undecodable")
        }

        print("🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢\n")
    }
}
