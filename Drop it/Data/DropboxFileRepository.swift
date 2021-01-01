//
//  DropboxFileRepository.swift
//  Drop it
//
//  Created by Sergio Bernal on 30/12/20.
//  Copyright © 2020 Sergio Bernal. All rights reserved.
//

import Foundation
import SwiftyDropbox
import RxSwift

enum RequestStatus {
    case started
    case finished
    case error
    case emptyData
}

class DropboxFileRepository: FilesRepository {
    
        
    var filesSubject = PublishSubject<DropboxFile>()
    var requestStatusSubject = PublishSubject<RequestStatus>()
    var imageDataSubject = PublishSubject<(DropboxFile,Data)>()
    
    var client: DropboxClient? {
        get {
            return DropboxClientsManager.authorizedClient
        }
    }
    
    func getFiles(for path: String) {
        requestStatusSubject.onNext(.started)
        client?.files.listFolder(path: path, includeMediaInfo: true, limit: 100).response(completionHandler: { (result, error) in
            if let error = error {
                print(error)
                self.requestStatusSubject.onNext(.error)
                UserDefaultsHelper.userIsLogged = false
                return
            }
            if let result = result {
                self.handleResult(result: result)
            } else {
                self.requestStatusSubject.onNext(.emptyData)
            }
        })
    }
    
    func getThumbnail(for dropboxFile: DropboxFile) {
        client?.files.getThumbnail(path: dropboxFile.path, format: .jpeg,size: .w32h32).response(completionHandler: { (response, error) in
            if let (_, data) = response {
                self.imageDataSubject.onNext((dropboxFile, data))
            }
        })
    }
    
    private func getNext(cursor: String) {
        client?.files.listFolderContinue(cursor: cursor).response(completionHandler: { (result, error) in
            if let error = error {
                print(error)
                self.requestStatusSubject.onNext(.error)
                UserDefaultsHelper.userIsLogged = false
                return
            }
            if let result = result {
                self.handleResult(result: result)
            } else {
                self.requestStatusSubject.onNext(.emptyData)
            }
        })
    }
    
    private func handleResult(result: Files.ListFolderResult) {
        
        result.entries.forEach { (fileMeta) in
            
            var file: DropboxFile?
            
            switch fileMeta {
            case let data as Files.FileMetadata:
                file = DropboxFile(id: data.id, cursor: result.cursor , name: fileMeta.name, path: fileMeta.pathLower ?? "", description: fileMeta.description, isFolder: false,dateModified: data.clientModified)
            case let data as Files.FolderMetadata:
                file = DropboxFile(id: data.id, cursor: result.cursor , name: fileMeta.name, path: fileMeta.pathLower ?? "", description: fileMeta.description, isFolder: true, dateModified: nil)
            default:
                print("fileMeta is not a folder or file")
            }
            if let file = file {
                self.filesSubject.onNext(file)
            }
        }
        
        if result.hasMore {
            self.getNext(cursor: result.cursor)
        } else {
            requestStatusSubject.onNext(.finished)
        }
    }
}
