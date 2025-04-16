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
    let isLoading = PublishSubject<Bool>()
    
    let articles = BehaviorRelay<[ArticleModel]>(value: [])
    let blogs = BehaviorRelay<[ArticleModel]>(value: [])
    let reports = BehaviorRelay<[ArticleModel]>(value: [])
    let errorMessage = ReplaySubject<String>.create(bufferSize: 1)
    
    private let articleService: ArticleProtocol
    private let blogService: BlogProtocol
    private let reportService: ReportProtocol
    
    private let limit: Int = 100
    
    init(articleService: ArticleProtocol, blogService: BlogProtocol, reportService: ReportProtocol) {
        self.articleService = articleService
        self.blogService = blogService
        self.reportService = reportService
    }
    
    
    func fetchArticles(keyword: String) {
        isLoading.onNext(true)
        articleService.fetchArticles(limit: limit, keyword)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] articles in
                guard let self = self else { return }
                self.articles.accept(articles)
                self.isLoading.onNext(false)
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.errorMessage.onNext(error.localizedDescription)
                self.isLoading.onNext(false)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchReports(keyword: String) {
        isLoading.onNext(true)
        reportService.fetchReports(limit: limit, "")
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] reports in
                guard let self = self else { return }
                self.reports.accept(reports)
                self.isLoading.onNext(false)
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.errorMessage.onNext(error.localizedDescription)
                self.isLoading.onNext(false)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchBlogs(keyword: String) {
        isLoading.onNext(true)
        blogService.fetchBlogs(limit: limit, keyword: "")
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] blogs in
                guard let self = self else { return }
                self.blogs.accept(blogs)
                self.isLoading.onNext(false)
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.errorMessage.onNext(error.localizedDescription)
                self.isLoading.onNext(false)
            })
            .disposed(by: disposeBag)
    }
    
}
