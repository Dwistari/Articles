//
//  BlogService.swift
//  Articles
//
//  Created by Dwistari on 15/04/25.
//

import Foundation
import RxSwift

protocol BlogProtocol {
    func fetchBlogs(limit: Int, keyword: String)  -> Observable<[ArticleModel]>
    func fetchDetailsBlog(id: Int) -> Observable<ArticleModel>
}

class BlogService: BlogProtocol {
    private let client = NetworkClient()
    
    func fetchBlogs(limit: Int, keyword: String) -> Observable<[ArticleModel]> {
        return Observable.create { observer in
            guard let url = makeURLWithQueryParams(limit: limit, keyword: keyword, endpoin: Endpoint.blogs.url) else {
                observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return Disposables.create()
            }
            self.client.request(url: url) { (result: Result<ResponseModel, Error>) in
                switch result {
                case .success(let response):
                    observer.onNext(response.results)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                    
                    
                    if let decodingError = error as? DecodingError {
                          switch decodingError {
                          case .dataCorrupted(let context):
                              print("Data corrupted:", context.debugDescription)
                          case .keyNotFound(let key, let context):
                              print("Key not found:", key, "-", context.debugDescription)
                          case .typeMismatch(let type, let context):
                              print("Type mismatch:", type, "-", context.debugDescription)
                          case .valueNotFound(let value, let context):
                              print("Value not found:", value, "-", context.debugDescription)
                          @unknown default:
                              print("Unknown decoding error")
                          }
                      }
                }
            }
            
            return Disposables.create()
        }
    }
    
    func fetchDetailsBlog(id: Int) -> Observable<ArticleModel> {
        return Observable.create { observer in
            guard let url = URL(string: Endpoint.detailReports(id: id).url) else {
                observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return Disposables.create()
            }
            
            self.client.request(url: url) { (result: Result<ArticleModel, Error>) in
                switch result {
                case .success(let detail):
                    observer.onNext(detail)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
}
