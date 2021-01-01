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
    var subjectUrl: PublishSubject<URL> { get }
    var subjectShowError: PublishSubject<String> { get }
    
    func getMainFiles()
    func getFilesForNext(index: Int)
    func getPreviousFiles()
    func getFileCount() -> Int
    func getFileFor(index: Int) -> DropboxFile
}

class FileExplorerViewModel: FileExplorerViewModelInterface {
    
    let subjectLoadingIndicator = PublishSubject<Bool>()
    let subjectReloadFiles = PublishSubject<Bool>()
    let subjectUrl = PublishSubject<URL>()
    let subjectShowError = PublishSubject<String>()
    
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
            if !file.isFolder {
                self?.repository.getThumbnail(for: file)
            }
        }).disposed(by: bag)
        
        repository.imageDataSubject.subscribe(onNext: { [weak self] (file, data) in
            self?.updateThumbnail(file: file, imageData: data)            
        }).disposed(by: bag)
        
        repository.fileUrlSubject.subscribe(onNext: { [weak self] url in            
            self?.subjectUrl.onNext(url)
            self?.subjectLoadingIndicator.onNext(false)
        }).disposed(by: bag)
        
        repository.errorSubject.subscribe(onNext: { [weak self] errorMessage in
            self?.subjectLoadingIndicator.onNext(false)
            self?.subjectShowError.onNext(errorMessage)
        }).disposed(by: bag)
        
        repository.requestStatusSubject.subscribe(onNext: { status in
            
            switch status {
            case .started:
                self.subjectLoadingIndicator.onNext(true)
            case .finished:
                self.filesBackUp[self.currentPage]?.sort(by: { $0.name < $1.name})
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
    
    func getFilesForNext(index: Int) {
        
        guard filesBackUp[currentPage]?[index].isFolder ?? false else {
            openFileIfSupported(index: index)
            return
        }
        
        subjectLoadingIndicator.onNext(true)
        
        let path = filesBackUp[currentPage]?[index].path ?? ""
        currentPage += 1
        
        filesBackUp[currentPage] = [DropboxFile]()
        repository.getFiles(for: path)
    }
    
    func getPreviousFiles() {
        guard currentPage > 0 else { return }
        
        subjectLoadingIndicator.onNext(true)
        
        currentPage -= 1
        
        subjectReloadFiles.onNext(true)
        subjectLoadingIndicator.onNext(false)
    }
    
    private func updateThumbnail(file: DropboxFile, imageData: Data) {
        for key in filesBackUp.keys {
            for i in 0..<(filesBackUp[key]?.count ?? 0) {
                if filesBackUp[key]?[i].id == file.id {
                    filesBackUp[key]?[i].thumbnail = UIImage(data: imageData)
                    subjectReloadFiles.onNext(true)
                    return
                }
            }
        }
    }
    
    func openFileIfSupported(index: Int) {
        subjectLoadingIndicator.onNext(true)
        
        if let file = filesBackUp[currentPage]?[index] {
            if file.name.hasSuffix(".jpg") || file.name.hasSuffix(".png") || file.name.hasSuffix(".pdf") {
                repository.downloadFile(for: file)
            } else {
                subjectLoadingIndicator.onNext(false)
                subjectShowError.onNext("File not supported for preview")
            }
        }
    }
    
    func getFileCount() -> Int { filesBackUp[currentPage]?.count ?? 0 }
    
    func getFileFor(index: Int) -> DropboxFile { filesBackUp[currentPage]?[index] ?? DropboxFile(id: "", cursor: "", name: "", path: "", description: "", isFolder: false, dateModified: nil) }
}
