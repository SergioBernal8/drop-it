//
//  LogInViewController.swift
//  Drop it
//
//  Created by Sergio Bernal on 30/12/20.
//  Copyright © 2020 Sergio Bernal. All rights reserved.
//

import UIKit
import RxSwift
import ProgressHUD
import SwiftyDropbox

class LogInViewController: UIViewController {
    
    var viewModel: LogInViewModelProtocol?
    
    let bag = DisposeBag()
    
    init(viewModel: LogInViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil) 
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
         super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Log In"
        view.backgroundColor = .white
        createButtonLoginButton()
        addBindings()
    }
    
    private func createButtonLoginButton(){
        let viewSize = view.frame.size
        let loginButton = UIButton(frame: CGRect(x:0, y: 0, width: viewSize.width * 0.8, height: 40))
        
        loginButton.center = view.center
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitle("Log In", for: .normal)
        loginButton.addTarget(self, action: #selector(buttonActionClick), for: .touchUpInside )
        
        
        view.addSubview(loginButton)
    }
    
    @objc func buttonActionClick(sender: UIButton!) {
        
        viewModel?.logUser(controller: self)
    }
    
    
    
    func addBindings() {
        viewModel?.subjectLogInSuccess.subscribe(onNext: { success in

        }).disposed(by: bag)
        
        viewModel?.subjectLoadingIndicator.subscribe(onNext: { loading in
            if loading {
                ProgressHUD.show()
            } else {
                ProgressHUD.dismiss()
            }
        }).disposed(by: bag)
    }
    
}
