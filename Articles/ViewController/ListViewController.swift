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

    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let sortControl = UISegmentedControl(items: ["Asc", "Desc"])

    private let originalNames = ["Alice", "Bob", "Charlie", "Diana", "Edward"]
    private var filteredNames: [String] = []
    
    private var searchText: String = ""
    private let disposeBag = DisposeBag()
    private var articles: [ArticleModel] = []

    var section: Int = 0
    
    private let viewModel = ListViewModel(articleService: ArticleService(), blogService: BlogService(), reportService: ReportService())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Detail"
        
        filteredNames = originalNames

        setupSearchBar()
        setupSortControl()
        setupTableView()
        fetchData("")
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search names"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
    }

    private func setupSortControl() {
        sortControl.selectedSegmentIndex = 0
        sortControl.addTarget(self, action: #selector(sortChanged), for: .valueChanged)
        sortControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sortControl)
    }

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            sortControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            sortControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sortControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: sortControl.bottomAnchor, constant: 8),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
        ])

        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchData(_ keyword: String) {
        self.showLoading()
        switch section {
        case 0:
            viewModel.fetchArticles(keyword: keyword)
        case 1:
            viewModel.fetchBlogs(keyword: keyword)
        case 2:
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
                self.tableView.reloadData()
                self.dismissLoading()
            })
            .disposed(by: disposeBag)
        
        viewModel.blogs
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] blog in
                guard let self = self else { return }
                self.articles = blog
                self.tableView.reloadData()
                self.dismissLoading()
            })
            .disposed(by: disposeBag)
        
        viewModel.reports
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] report in
                guard let self = self else { return }
                self.articles = report
                self.tableView.reloadData()
                self.dismissLoading()
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                print("errorMessage", error.debugDescription)
            })
            .disposed(by: disposeBag)
    }
    

    @objc private func sortChanged() {
        applyFilterAndSort()
    }

    private func applyFilterAndSort() {
        let isAscending = sortControl.selectedSegmentIndex == 0
        searchText = searchBar.text?.lowercased() ?? ""
        fetchData(searchText)
        
        // Filter
        filteredNames = originalNames.filter { name in
            name.lowercased().contains(searchText)
        }

        // Sort
        filteredNames.sort(by: isAscending ? (<) : (>))

        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ArticleTableViewCell
        cell.configure(data: articles[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped on: \(filteredNames[indexPath.row])")
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension ListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilterAndSort()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        applyFilterAndSort()
        searchBar.resignFirstResponder()
    }
}
