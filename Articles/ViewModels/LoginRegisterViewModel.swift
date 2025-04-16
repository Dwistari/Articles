//
//  LoginRegisterViewModel.swift
//  Articles
//
//  Created by Dwistari on 14/04/25.
//

import Foundation
import RxSwift
import Auth0

class LoginRegisterViewModel {
    
    private let authService: AuthService
    private let disposeBag = DisposeBag()
    
    let successAuth = PublishSubject<Void>()
    let errorResponse = PublishSubject<String>()
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
    }
    
    func loginAuth() {
        authService.login()
            .subscribe(
                onNext: { [weak self] in
                    guard let self = self else { return }
                    self.successAuth.onNext(())
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    self.errorResponse.onNext(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func registerAuth() {
        authService.register()
            .subscribe(
                onNext: { [weak self] in
                    guard let self = self else { return }
                    self.successAuth.onNext(())
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    self.errorResponse.onNext(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
}
