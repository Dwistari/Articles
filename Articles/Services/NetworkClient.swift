//
//  NetworkClient.swift
//  Articles
//
//  Created by Dwistari on 15/04/25.
//

import Foundation

class NetworkClient {
    private let session: URLSession
    
    init() {
        let delegate = SSLPinningDelegate()
        session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
    }

    func request<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        let task = session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
