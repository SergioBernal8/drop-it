//
//  LogInViewModel.swift
//  Drop it
//
//  Created by Sergio Bernal on 30/12/20.
//  Copyright © 2020 Sergio Bernal. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyDropbox

protocol LogInViewModelInterface {
    var subjectLogInSuccess:PublishSubject<Bool> { get }
    var subjectLoadingIndicator:PublishSubject<Bool> { get }
    var dropboxOAuthCompletion: DropboxOAuthCompletion { get }
    
    func logUser(controller: UIViewController)
    func checkLogStatus() -> Bool
}

class LogInViewModel: LogInViewModelInterface {
        
    let subjectLoadingIndicator =  PublishSubject<Bool>()
    let subjectLogInSuccess = PublishSubject<Bool>()
    
    var dropboxOAuthCompletion: DropboxOAuthCompletion {
        get {
            return completion
        }
    }
    
    func completion(result: DropboxOAuthResult?) {
        if let authResult = result {
            switch authResult {
            case .success:
                UserDefaultsHelper.userIsLogged = true
                subjectLogInSuccess.onNext(true)
            case .cancel:
                UserDefaultsHelper.userIsLogged = false
                print("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                UserDefaultsHelper.userIsLogged = false
                print("Error: \(String(describing: description))")
            }
        }
    }
    
    func checkLogStatus() -> Bool {
        let userIsLogged = UserDefaultsHelper.userIsLogged
        if userIsLogged {
            subjectLogInSuccess.onNext(true)
        }
        return userIsLogged
    }
    
    func logUser(controller: UIViewController) {
        
        DropboxClientsManager.authorizeFromControllerV2(UIApplication.shared, controller: controller, loadingStatusDelegate: self, openURL: { (url) in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }, scopeRequest: nil)
    }
}

// MARK: LoadingStatusDelegate

extension LogInViewModel: LoadingStatusDelegate {
    func showLoading() {
        subjectLoadingIndicator.onNext(true)
    }
    
    func dismissLoading() {
        subjectLoadingIndicator.onNext(false)
    }
}
