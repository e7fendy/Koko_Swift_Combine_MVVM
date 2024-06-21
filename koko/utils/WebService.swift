//
//  WebService.swift
//  koko
//
//  Created by 吳昭泉 on 2024/6/18.
//

import Foundation

class WebService {
    
    enum NetworkError: Error {
        case decodingError
        case domainError
        case urlError
    }
    
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
    }

    struct Resource<T: Codable> {
        let url: URL
        var method = HttpMethod.get
        var body: Data?
    }
    
    static let shared = WebService()
    
    
    func load<T>(_ resource: Resource<T>, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        var request = URLRequest(url: resource.url)
        request.httpMethod = resource.method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                completion(.failure(.domainError))
                return
            }
            
            let result = try? JSONDecoder().decode(T.self, from: data)
            
            if let result = result {
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } else {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}
