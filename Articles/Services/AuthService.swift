//
//  AuthService.swift
//  Articles
//
//  Created by Dwistari on 15/04/25.
//

import RxSwift
import Auth0
import UIKit

protocol AuthProtocol {
    func login() -> Observable<Void>
    func register() -> Observable<Void>
}

class AuthService: AuthProtocol {
    
    func login() -> Observable<Void> {
        return createAuthObservable(
            authBuilder: Auth0
                .webAuth()
                .scope("openid profile email")
                .parameters(["prompt": "login"])
                .redirectURL(URL(string: "articles://auth/callback")!)
        )
    }
    
    func register() -> Observable<Void> {
        return createAuthObservable(
            authBuilder: Auth0
                .webAuth()
                .scope("openid profile email")
                .audience("https://dev-ruvw45til07wi8t1.us.auth0.com/userinfo")
                .parameters(["screen_hint": "signup", "prompt": "login"])
                .redirectURL(URL(string: "articles://auth/callback")!)
        )
    }
    
    private func createAuthObservable(authBuilder: WebAuth) -> Observable<Void> {
        return Observable.create { observer in
            authBuilder.start { result in
                switch result {
                case .success:
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
