//
//  DropboxFile.swift
//  Drop it
//
//  Created by Sergio Bernal on 30/12/20.
//  Copyright © 2020 Sergio Bernal. All rights reserved.
//

import Foundation
import UIKit

struct DropboxFile {
    
    let id: String
    let cursor: String
    let name: String
    let path: String
    let description: String
    let isFolder: Bool
    let dateModified: Date?
    var thumbnail: UIImage? = nil
    
}
