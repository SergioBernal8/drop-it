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
    
    private var tableView: UITableView!
    
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
        
        addListView()
        addBindings()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.viewModel?.getMainFiles()
        }
    }
    
    private func addListView(){
        let size = view.frame.size
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FileTableViewCell.self, forCellReuseIdentifier: "FileCell")
        
        view.addSubview(tableView)
    }
    
    private func addBindings() {
        
        viewModel?.subjectLoadingIndicator.subscribe(onNext: { loading in
            if loading {
                ProgressHUD.show()
            } else {
                ProgressHUD.dismiss()
            }
        }).disposed(by: bag)
        
        viewModel?.subjectReloadFiles.subscribe(onNext: { reload in
            if reload {
                self.tableView.reloadData()
            }
        }).disposed(by: bag)
    }
    
}

// MARK: UITableViewDataSource
extension FileExplorerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }
}


// MARK: UITableViewDataSource
extension FileExplorerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { viewModel?.getFileCount() ?? 0 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath as IndexPath) as? FileTableViewCell, let viewModel = viewModel{
            cell.model = viewModel.getFileFor(index: indexPath.row)
            return cell
        }
        return UITableViewCell()
    }
    
}
