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
import QuickLook

class FileExplorerViewController: UIViewController {
    
    var viewModel: FileExplorerViewModelInterface?
    
    let bag = DisposeBag()
    
    private var previewUrl = [URL]()
    
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
        
        addNavBar()
        addListView()
        addBindings()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.viewModel?.getMainFiles()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewUrl.removeAll()
    }
    
    @objc func backButtonPresses() {
        viewModel?.getPreviousFiles()
    }
    
    private func addNavBar() {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 12, width: view.frame.size.width, height: 44))
        navBar.barTintColor = .white
        navBar.tintColor = .black
        
        let image = UIImage(named: "backIcon")
        let navItem = UINavigationItem(title: "Files")
        let backButton = UIBarButtonItem(image: image, style: .plain, target: nil, action: #selector(backButtonPresses))
        
        navItem.leftBarButtonItem = backButton
        navBar.setItems([navItem], animated: false)
        view.addSubview(navBar)
    }
    
    private func addListView(){
        let size = view.frame.size
        tableView = UITableView(frame: CGRect(x: 0, y: 56, width: size.width, height: size.height))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(FolderTableViewCell.self, forCellReuseIdentifier: "FolderCell")
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
        
        viewModel?.subjectUrl.subscribe(onNext: { url in
            self.goToViewer(url: url)
        }).disposed(by: bag)
        
        viewModel?.subjectShowError.subscribe(onNext: { errorMessage in
            self.showError(with: errorMessage)
        }).disposed(by: bag)
        
        viewModel?.subjectReloadFiles.subscribe(onNext: { reload in
            if reload {
                self.tableView.reloadData()
            }
        }).disposed(by: bag)
    }
    
    private func goToViewer(url: URL) {
        previewUrl.append(url)
        
        let controller = QLPreviewController()
        controller.dataSource = self
        present(controller, animated: true, completion: nil)        
    }
    
    private func showError(with message: String){
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
            alertController.dismiss(animated: true, completion: nil)
        }))

        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: UITableViewDataSource

extension FileExplorerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.getFilesForNext(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }
}


// MARK: UITableViewDataSource

extension FileExplorerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { viewModel?.getFileCount() ?? 0 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let model = viewModel?.getFileFor(index: indexPath.row) {
            if model.isFolder {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath as IndexPath) as? FolderTableViewCell {
                    cell.model = model
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath as IndexPath) as? FileTableViewCell {
                    cell.model = model
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
}

// MARK: QLPreviewControllerDataSource

extension FileExplorerViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { previewUrl.count }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        previewUrl[index] as QLPreviewItem
    }        
}
