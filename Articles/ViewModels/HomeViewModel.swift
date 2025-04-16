//
//  HomeViewModel.swift
//  Articles
//
//  Created by Dwistari on 15/04/25.
//

import RxSwift
import RxCocoa

class HomeViewModel {
    
    private let disposeBag = DisposeBag()
    
    let articles = BehaviorRelay<[ArticleModel]>(value: [])
    let blogs = BehaviorRelay<[ArticleModel]>(value: [])
    let reports = BehaviorRelay<[ArticleModel]>(value: [])
    let errorMessage = ReplaySubject<String>.create(bufferSize: 1)
    
    private let articleService: ArticleProtocol
    private let blogService: BlogProtocol
    private let reportService: ReportProtocol
    
    private let limit: Int = 3

    init(articleService: ArticleProtocol, blogService: BlogProtocol, reportService: ReportProtocol) {
        self.articleService = articleService
        self.blogService = blogService
        self.reportService = reportService
    }
    
    
    func fetchAll() {
        fetchArticles()
        fetchBlogs()
        fetchReports()
    }
    
    private func fetchArticles() {
        articleService.fetchArticles(limit: limit, "")
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] articles in
                self?.articles.accept(articles)
            }, onError: { [weak self] error in
                self?.errorMessage.onNext(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchReports() {
        reportService.fetchReports(limit: limit, "")
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] reports in
                self?.reports.accept(reports)
            }, onError: { [weak self] error in
                self?.errorMessage.onNext(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchBlogs() {
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
