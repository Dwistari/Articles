//
//  BaseViewController.swift
//  Articles
//
//  Created by Dwistari on 15/04/25.
//

import UIKit

class BaseViewController: UIViewController {

    var sessionTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func showToastError(message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        let textSize = toastLabel.intrinsicContentSize
        let labelWidth = min(textSize.width, self.view.frame.width - 40)
        
        toastLabel.frame = CGRect(
            x: self.view.frame.width / 2 - (labelWidth + 20) / 2,
            y: self.view.frame.height - 100,
            width: labelWidth + 20,
            height: textSize.height + 20
        )
        
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }

}
