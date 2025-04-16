//
//  HomeViewController.swift
//  Articles
//
//  Created by Dwistari on 14/04/25.
//

import RxSwift
import UIKit

final class HomeViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    private var articles: [ArticleModel] = []
    private var blogs: [ArticleModel] = []
    private var reports: [ArticleModel] = []
    
    private var sectionStates: [HomeSection: SectionState] = [
        .articles: .loading,
        .blogs: .loading,
        .reports: .loading
    ]
    
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.text = "Good Morning 👋"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let viewModel = HomeViewModel(articleService: ArticleService(), blogService: BlogService(), reportService: ReportService())
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        setupConstraints()
        configureGreeting()
        startSessionTimer()
        bindViewModel()
    }
    
    // MARK: - Setup UI
    
    private func setupViews() {
        view.addSubview(greetingLabel)
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SectionTableViewCell.self, forCellReuseIdentifier: "SectionCell")
        tableView.separatorStyle = .none
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            greetingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        ])
    }
    
    private func bindViewModel() {
        viewModel.fetchAll()
        viewModel.articles
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] articles in
                guard let self = self else { return }
                self.articles = articles
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.blogs
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] blog in
                guard let self = self else { return }
                self.blogs = blog
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.reports
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] report in
                guard let self = self else { return }
                self.reports = report
                self.tableView.reloadData()
                
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showToastError(message: error.debugDescription)
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Greeting Logic
    
    private func configureGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            greetingLabel.text = "Good Morning 👋"
        case 12..<17:
            greetingLabel.text = "Good Afternoon ☀️"
        case 17..<22:
            greetingLabel.text = "Good Evening 🌇"
        default:
            greetingLabel.text = "Good Night 🌙"
        }
    }
    
    @objc private func openDetail(_ sender: UIButton) {
        let vc = ListViewController()
        let section = sender.tag
        vc.section = section
        
        print("sender.tag", sender.tag)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return HomeSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return HomeSection(rawValue: section)?.title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150 
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 16)
        switch section {
        case 0: titleLabel.text = "artikel"
        case 1: titleLabel.text = "blog"
        case 2: titleLabel.text = "report"
        default: break
        }
        
        let seeMore = UIButton(type: .system)
        seeMore.setTitle("see more", for: .normal)
        seeMore.titleLabel?.font = .systemFont(ofSize: 14)
        seeMore.tag = section 
        seeMore.addTarget(self, action:#selector(openDetail(_:)), for: .touchUpInside)

        container.addSubview(titleLabel)
        container.addSubview(seeMore)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        seeMore.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            seeMore.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            seeMore.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SectionCell", for: indexPath) as? SectionTableViewCell else {
            return UITableViewCell()
        }
        if let section = HomeSection(rawValue: indexPath.section) {
            switch section {
            case .articles:
                cell.configure(with: articles.map { $0.image_url ?? "" })
            case .blogs:
                cell.configure(with: blogs.map { $0.image_url ?? "" })
            case .reports:
                cell.configure(with: reports.map { $0.image_url ?? ""})
            }
        }
        return cell
    }
}


enum HomeSection: Int, CaseIterable {
    case articles
    case blogs
    case reports
    
    var title: String {
        switch self {
        case .articles: return "Articles"
        case .blogs: return "Blogs"
        case .reports: return "Reports"
        }
    }
}
