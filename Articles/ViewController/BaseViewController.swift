//
//  BaseViewController.swift
//  Articles
//
//  Created by Dwistari on 15/04/25.
//

import UIKit

class BaseViewController: UIViewController {

    var sessionTimer: Timer?
    
    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func startSessionTimer(with interval: TimeInterval = 600) {
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(sessionExpired), userInfo: nil, repeats: false)
        RunLoop.main.add(sessionTimer!, forMode: .common)
    }
    
    @objc func sessionExpired() {
        SessionManager.shared.onLogout = {
            let vc = LoginRegisterViewController()
            self.navigationController?.setViewControllers([vc], animated: true)
        }
        SessionManager.shared.logoutUser()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionTimer?.invalidate()
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
    }
    
    func dismissLoading() {
        loadingIndicator.stopAnimating()
    }
}
