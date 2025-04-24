//
//  ViewController.swift
//  Articles
//
//  Created by Dwistari on 14/04/25.
//

import UIKit
import RxSwift
import UserNotifications

final class LoginRegisterViewController: BaseViewController {

    private let disposeBag = DisposeBag()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Login"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = UIColor.black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupActions()
        handleAuth()
    }
    
    var viewModel: LoginRegisterViewModel = {
        let viewModel = LoginRegisterViewModel()
        return viewModel
    }()

    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, loginButton, registerButton])
        stackView.axis = .vertical
        stackView.spacing = 16

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
    }

    @objc private func handleLogin() {
        viewModel.loginAuth()
    }
    
    @objc private func handleRegister() {
        viewModel.registerAuth()
    }
    
    private func handleAuth() {
        viewModel.successAuth
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.handleSuccessfulAuth()
            })
            .disposed(by:disposeBag)
        
        viewModel.errorResponse
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self = self else { return }
                self.showToastError(message: error.debugDescription)
            })
            .disposed(by:disposeBag)
    }
    
    private func navigateToHomeScreen() {
        let vc = HomeViewController()
        navigationController?.setViewControllers([vc], animated: true)
      }
    
    func handleSuccessfulAuth() {
        let now = Date()
        UserDefaults.standard.set(now, forKey: "loginDate")
        navigateToHomeScreen()
    }
}
