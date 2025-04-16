//
//  ReportService.swift
//  Articles
//
//  Created by Dwistari on 15/04/25.
//

import RxSwift
import Foundation

protocol ReportProtocol {
    func fetchReports(limit: Int, _ keyword: String) -> Observable<[ArticleModel]>
    func fetchDetailsReports(id: Int) -> Observable<ArticleModel>
}

class ReportService: ReportProtocol {
    private let client = NetworkClient()
    
    func fetchReports(limit: Int, _ keyword: String = "") -> Observable<[ArticleModel]> {
        return Observable.create { observer in
            guard let url = makeURLWithQueryParams(limit: limit, keyword: keyword, endpoin: Endpoint.reports.url) else {
                observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return Disposables.create()
            }
            self.client.request(url: url) { (result: Result<ResponseModel, Error>) in
                print("url---fetchReports", url)

                switch result {
                case .success(let response):
                    observer.onNext(response.results)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
    
                }
            }
            
            return Disposables.create()
        }
    }
    
    func fetchDetailsReports(id: Int) -> Observable<ArticleModel> {
        return Observable.create { observer in
            guard let url = URL(string: Endpoint.detailReports(id: id).url) else {
                observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return Disposables.create()
            }
            
            self.client.request(url: url) { (result: Result<ArticleModel, Error>) in
                switch result {
                case .success(let response):
                    observer.onNext(response)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
}
