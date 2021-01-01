//
//  DropboxFile.swift
//  Drop it
//
//  Created by Sergio Bernal on 30/12/20.
//  Copyright © 2020 Sergio Bernal. All rights reserved.
//

import Foundation

struct DropboxFile {
    
    let cursor: String
    let name: String
    let path: String
    let description: String
    let isFolder: Bool
    let dateModified: Date?
    
}
