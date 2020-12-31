//
//  FileExplorerViewModel.swift
//  Drop it
//
//  Created by Sergio Bernal on 30/12/20.
//  Copyright © 2020 Sergio Bernal. All rights reserved.
//

import Foundation
import RxSwift

protocol FileExplorerViewModelInterface {
    var repository: FilesRepository { get }
    
    var subjectLoadingIndicator: PublishSubject<Bool> { get }
    var subjectReloadFiles: PublishSubject<Bool> { get }
    
    func getMainFiles()
    func getFilesForNext(path: String)
    func getPreviousFiles()
    func getFileCount() -> Int
    func getFileFor(index: Int) -> DropboxFile
}

class FileExplorerViewModel: FileExplorerViewModelInterface {
    
    let subjectLoadingIndicator = PublishSubject<Bool>()
    let subjectReloadFiles = PublishSubject<Bool>()
    
    let repository: FilesRepository
    let bag = DisposeBag()
    var filesBackUp = [Int:[DropboxFile]]()
    
    private var currentPage = 0
    
    init(repository: FilesRepository) {
        self.repository = repository
        addBindings()
    }
    
    private func addBindings() {
        
        repository.filesSubject.subscribe(onNext: { [weak self] file in
            self?.filesBackUp[self?.currentPage ?? 0]?.append(file)
            self?.filesBackUp[self?.currentPage ?? 0]?.sort(by: { $0.name < $1.name})
        }).disposed(by: bag)
        
        repository.requestStatusSubject.subscribe(onNext: { status in
            
            switch status {
            case .started:
                self.subjectLoadingIndicator.onNext(true)
            case .finished:
                self.subjectReloadFiles.onNext(true)
                self.subjectLoadingIndicator.onNext(false)
            case .error:
                self.subjectLoadingIndicator.onNext(false)
            case .emptyData:
                self.subjectLoadingIndicator.onNext(false)
            }
            
        }).disposed(by: bag)
    }
    
    // MARK: FileExplorerViewModelInterface
    
    func getMainFiles() {
        filesBackUp[currentPage] = [DropboxFile]()
        repository.getFiles(for: "")
    }
    
    func getFilesForNext(path: String) {
        currentPage += 1
        filesBackUp[currentPage] = [DropboxFile]()
        repository.getFiles(for: path)
    }
    
    func getPreviousFiles() {
        guard currentPage > 0 else { return }
        currentPage -= 1
        
        filesBackUp[currentPage]?.forEach({ (file) in
            self.subjectReloadFiles.onNext(true)
        })
    }
    
    func getFileCount() -> Int { filesBackUp[currentPage]?.count ?? 0 }
    
    func getFileFor(index: Int) -> DropboxFile { filesBackUp[currentPage]?[index] ?? DropboxFile(cursor: "", name: "", path: "", description: "", isFolder: false) }
}
