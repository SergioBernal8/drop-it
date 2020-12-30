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

protocol LogInViewModelProtocol {
    var subjectLogInSuccess:PublishSubject<Bool> { get }
    var subjectLoadingIndicator:PublishSubject<Bool> { get }
    var dropboxOAuthCompletion: DropboxOAuthCompletion { get }
    
    func logUser(controller: UIViewController)
}

class LogInViewModel: LogInViewModelProtocol {
    
    let subjectLoadingIndicator =  PublishSubject<Bool>()
    let subjectLogInSuccess = PublishSubject<Bool>()
    
    var dropboxOAuthCompletion: DropboxOAuthCompletion = {
        if let authResult = $0 {
            switch authResult {
            case .success:
                print("Success! User is logged into DropboxClientsManager.")
            case .cancel:
                print("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                print("Error: \(String(describing: description))")
            }
        }
    }
    
    
    func logUser(controller: UIViewController) {
        DropboxClientsManager.authorizeFromControllerV2(UIApplication.shared, controller: controller, loadingStatusDelegate: self, openURL: { (url) in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }, scopeRequest: nil)
    }
}


extension LogInViewModel: LoadingStatusDelegate {
    func showLoading() {
        subjectLoadingIndicator.onNext(true)
    }
    
    func dismissLoading() {
        subjectLoadingIndicator.onNext(false)
    }
}
