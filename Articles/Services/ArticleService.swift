//
//  ArticleService.swift
//  Articles
//
//  Created by Dwistari on 15/04/25.
//

import Foundation
import RxSwift

protocol ArticleProtocol {
    func fetchArticles(limit: Int, _ keyword: String) -> Observable<[ArticleModel]>
    func fetchDetailsArticle(id: Int) -> Observable<ArticleModel>
}

class ArticleService: ArticleProtocol {
    private let client = NetworkClient()
    
    func fetchArticles(limit: Int, _ keyword: String = "") -> Observable<[ArticleModel]> {
          return Observable.create { observer in
              guard let url = makeURLWithQueryParams(limit: limit, keyword: keyword, endpoin: Endpoint.articles.url) else {
                        observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                        return Disposables.create()
                    }
              self.client.request(url: url) { (result: Result<ResponseModel, Error>) in
                  switch result {
                  case .success(let response):
                      observer.onNext(response.results)
                      observer.onCompleted()
                  case .failure(let error):
                      print("error---", error.localizedDescription)
                      observer.onError(error)
                  }
              }
              
              return Disposables.create()
          }
      }
    
    func fetchDetailsArticle(id: Int) -> Observable<ArticleModel> {
        return Observable.create { observer in
            guard let url = URL(string: Endpoint.detailReports(id: id).url) else {
                observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return Disposables.create()
            }
            
            self.client.request(url: url) { (result: Result<ArticleModel, Error>) in
                switch result {
                case .success(let reports):
                    observer.onNext(reports)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
}

func makeURLWithQueryParams(limit: Int, keyword: String, endpoin: String) -> URL? {
    var components = URLComponents(string: endpoin)
    components?.queryItems = [
        URLQueryItem(name: "limit", value: "\(limit)"),
        URLQueryItem(name: "search", value: "\(keyword)"),
    ]
    return components?.url
}
