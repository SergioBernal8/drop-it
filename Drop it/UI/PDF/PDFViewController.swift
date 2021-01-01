//
//  PDFViewController.swift
//  Drop it
//
//  Created by Sergio Bernal on 1/01/21.
//  Copyright © 2021 Sergio Bernal. All rights reserved.
//

import UIKit
import QuickLook

class PDFViewController: QLPreviewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
    }
    
}

extension PDFViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        urls.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return urls[index] as QLPreviewItem
    }
}
