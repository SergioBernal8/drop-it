//
//  FilesRepository.swift
//  Drop it
//
//  Created by Sergio Bernal on 30/12/20.
//  Copyright © 2020 Sergio Bernal. All rights reserved.
//

import Foundation
import SwiftyDropbox
import RxSwift

protocol FilesRepository {
    var client: DropboxClient? { get }
    
    var filesSubject: PublishSubject<DropboxFile> { get }
    var requestStatusSubject: PublishSubject<RequestStatus> { get }
    var imageDataSubject: PublishSubject<(DropboxFile,Data)> { get }
    
    func getFiles(for path: String)
    func getThumbnail(for dropboxFile: DropboxFile)
}
