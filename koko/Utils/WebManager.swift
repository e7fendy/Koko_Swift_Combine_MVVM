//
//  WebManager.swift
//  koko
//
//  Created by 吳昭泉 on 2024/6/18.
//

import Foundation
import Combine

class WebManager {
    
    static let shared = WebManager()
    
    func getUserInfo() -> AnyPublisher<UserInfo, WebService.NetworkError> {
        return Future<UserInfo, WebService.NetworkError> { promise in
            guard let url = URL(string: "https://dimanyen.github.io/man.json") else {
                promise(.failure(.urlError))
                return
            }
            
            let resource = WebService.Resource<UserInfo>(url: url)
            WebService.shared.load(resource) { result in
                if case .failure(let error) = result {
                    return promise(.failure(error))
                }
                
                do {
                    let data = try result.get()
                    promise(.success(data))
                } catch {
                    promise(.failure(.decodingError))
                }

            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func getFriendsInfo(by url: String) -> AnyPublisher<FriendsInfo, WebService.NetworkError> {
        return Future<FriendsInfo, WebService.NetworkError> { promise in
            guard let myUrl = URL(string: url) else {
                promise(.failure(.urlError))
                return
            }
            
            let resource = WebService.Resource<FriendsInfo>(url: myUrl)
            WebService.shared.load(resource) { result in
                if case .failure(let error) = result {
                    return promise(.failure(error))
                }
                
                do {
                    let data = try result.get()
                    promise(.success(data))
                } catch {
                    promise(.failure(.decodingError))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
