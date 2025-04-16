//
//  HomeService.swift
//  Articles
//
//  Created by Dwistari on 15/04/25.
//

import Foundation

class HomeService {
    static let shared = HomeService()
    
    private init() {}
    
    func getArticles(from urlString: String, completion: @escaping (Result<[ArticleModel], Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let articles = try JSONDecoder().decode([ArticleModel].self, from: data)
                completion(.success(articles))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    enum APIError: Error {
        case invalidURL
        case noData
    }
}
