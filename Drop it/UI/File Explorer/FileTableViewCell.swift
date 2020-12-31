//
//  FileTableViewCell.swift
//  Drop it
//
//  Created by Sergio Bernal on 31/12/20.
//  Copyright © 2020 Sergio Bernal. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class FileTableViewCell: UITableViewCell {
    
    var model: DropboxFile {
        didSet{
           setUpData()
        }
    }
    
    var label: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.model = DropboxFile(cursor: "", name: "", path: "", description: "", isFolder: false)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpCell() {
        super.awakeFromNib()
        label = UILabel(frame: .zero)
        label.text = "Hola"
        label.textColor = .black
        
        contentView.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.width.equalTo(200)
            make.left.equalToSuperview().offset(10)
            make.center.equalToSuperview()
        }
    }
    
    func setUpData() {
        label.text = model.name
    }
}
