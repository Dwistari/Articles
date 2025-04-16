//
//  ListViewModel.swift
//  Articles
//
//  Created by Dwistari on 16/04/25.
//

import RxSwift
import RxCocoa


class ListViewModel {
    
    private let disposeBag = DisposeBag()
    
    let articles = BehaviorRelay<[ArticleModel]>(value: [])
    let blogs = BehaviorRelay<[ArticleModel]>(value: [])
    let reports = BehaviorRelay<[ArticleModel]>(value: [])
    let errorMessage = ReplaySubject<String>.create(bufferSize: 1)
    
    private let articleService: ArticleProtocol
    private let blogService: BlogProtocol
    private let reportService: ReportProtocol
    
    private let limit: Int = 10
    
    init(articleService: ArticleProtocol, blogService: BlogProtocol, reportService: ReportProtocol) {
        self.articleService = articleService
        self.blogService = blogService
        self.reportService = reportService
    }
    
    
    func fetchArticles(keyword: String) {
        articleService.fetchArticles(limit: limit, keyword)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] articles in
                self?.articles.accept(articles)
            }, onError: { [weak self] error in
                self?.errorMessage.onNext(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchReports(keyword: String) {
        reportService.fetchReports(limit: limit, "")
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] reports in
                self?.reports.accept(reports)
            }, onError: { [weak self] error in
                self?.errorMessage.onNext(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchBlogs(keyword: String) {
        blogService.fetchBlogs(limit: limit, keyword: "")
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] blogs in
                self?.blogs.accept(blogs)
            }, onError: { [weak self] error in
                self?.errorMessage.onNext(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
}
