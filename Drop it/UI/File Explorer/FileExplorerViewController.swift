//
//  FileExplorerViewController.swift
//  Drop it
//
//  Created by Sergio Bernal on 30/12/20.
//  Copyright © 2020 Sergio Bernal. All rights reserved.
//

import UIKit
import RxSwift
import ProgressHUD

class FileExplorerViewController: UIViewController {
    
    var viewModel: FileExplorerViewModelInterface?
    
    let bag = DisposeBag()
    
    init(viewModel: FileExplorerViewModelInterface) {
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
        
        view.backgroundColor = .white
        title = "File Explorer"
        
        addBindings()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.viewModel?.getMainFiles()
        }
    }
    
    private func addBindings() {
        
        viewModel?.subjectLoadingIndicator.subscribe(onNext: { loading in
            if loading {
                ProgressHUD.show()
            } else {
                ProgressHUD.dismiss()
            }
        }).disposed(by: bag)
    }
    
}
