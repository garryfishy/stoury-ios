//
//  APIService.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError
    case encodingError
    case unknown
    
    var errorDescription: String? {
           switch self {
           case .invalidURL:
               return "The URL is invalid."
           case .invalidResponse:
               return "The server response was invalid."
           case .serverError(let statusCode):
               return "Server returned status code \(statusCode)."
           case .decodingError:
               return "Failed to read server data."
           case .encodingError:
               return "Failed to encode request data."
           case .unknown:
               return "Something went wrong."
           }
       }
}

final class APIService {
    private let baseURL = "https://stoury-api.oceandigital.id"
    
    func login (email: String, password: String) async throws -> AuthSession {
        guard let url = URL(string: "\(baseURL)/login") else {
                    throw APIError.invalidURL
                }
        let loginRequest = LoginRequest(email: email, password: password)
        
        var request = URLRequest(url: url )
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(loginRequest)

        let (data, response) = try await URLSession.shared.data(for: request)
        
        
        
        guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }

                guard 200...299 ~= httpResponse.statusCode else {
                    throw APIError.serverError(statusCode: httpResponse.statusCode)
                }

                do {
                    let decoded = try JSONDecoder().decode(APIResponse<AuthSession>.self, from: data)
                    return decoded.data

                } catch {
                    throw APIError.decodingError
                }
    }
}
