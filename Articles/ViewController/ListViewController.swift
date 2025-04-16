//
//  DetailViewController.swift
//  Articles
//
//  Created by Dwistari on 16/04/25.
//

import Foundation
import UIKit
import RxSwift

class ListViewController: BaseViewController {

    private lazy var dataNotFoundLbl: UILabel = {
        let label = UILabel()
        label.text = "Data Not Found"
        label.isHidden = true
        label.textColor = .gray
        label.font = .boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let sortControl = UISegmentedControl(items: ["Asc", "Desc"])
    private var searchText: String = ""
    private var articles: [ArticleModel] = []
    private let disposeBag = DisposeBag()
    
    var section: Int = 0
    
    private let viewModel = ListViewModel(
        articleService: ArticleService(),
        blogService: BlogService(),
        reportService: ReportService()
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        fetchData("")
    }

    private func setupViews() {
        setupSearchBar()
        setupSortControl()
        setupTableView()
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search article"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func setupSortControl() {
        sortControl.selectedSegmentIndex = 1
        sortControl.addTarget(self, action: #selector(applySorting), for: .valueChanged)
        sortControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sortControl)

        NSLayoutConstraint.activate([
            sortControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            sortControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sortControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: sortControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
        ])
        
        
        view.addSubview(dataNotFoundLbl)
        NSLayoutConstraint.activate([
            dataNotFoundLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dataNotFoundLbl.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        view.addSubview(loadingIndicator)
          NSLayoutConstraint.activate([
              loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
          ])
        
        view.bringSubviewToFront(loadingIndicator)

        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func fetchData(_ keyword: String) {
        showLoading()
        switch section {
        case 0:
            title = "Articles"
            viewModel.fetchArticles(keyword: keyword)
        case 1:
            title = "Blogs"
            viewModel.fetchBlogs(keyword: keyword)
        case 2:
            title = "Reports"
            viewModel.fetchReports(keyword: keyword)
        default:
            print("Unknown section: \(section)")
        }
        
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.articles
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] articles in
                guard let self = self else { return }
                self.articles = articles
            })
            .disposed(by: disposeBag)

        viewModel.blogs
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] blogs in
                guard let self = self else { return }
                self.articles = blogs
            })
            .disposed(by: disposeBag)

        viewModel.reports
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] reports in
                guard let self = self else { return }
                self.articles = reports
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.dismissLoading()
                    self?.updateUI()
                }
            })
            .disposed(by: disposeBag)

        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { error in
                self.showToastError(message: error.debugDescription)
            })
            .disposed(by: disposeBag)
    }

    private func updateUI() {
        dataNotFoundLbl.isHidden = !articles.isEmpty
        tableView.reloadData()
    }

    private func applySearch() {
        searchText = searchBar.text?.lowercased() ?? ""
        fetchData(searchText)
        tableView.reloadData()
    }
    
    @objc private func applySorting() {
        let isAscending = sortControl.selectedSegmentIndex == 0
        let sortedArticles = articles.sorted { first, second in
            guard let date1 = first.published_at, let date2 = second.published_at else { return false }
            return isAscending ? (date1 < date2) : (date1 > date2)
        }
        self.articles = sortedArticles
        tableView.reloadData()
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
    }
    
    func dismissLoading() {
        loadingIndicator.stopAnimating()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {     
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(data: articles[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension ListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySearch()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        if !articles.isEmpty {
            applySorting()
        } else {
            fetchData("")
        }
    }
}
