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

class FolderTableViewCell: UITableViewCell {
    
    var model: DropboxFile {
        didSet {
            setUpData()
        }
    }
    
    var titleLabel: UILabel!
    var folderImage: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.model = DropboxFile(cursor: "", name: "", path: "", description: "", isFolder: false, dateModified: nil)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpCell() {
        titleLabel = UILabel(frame: .zero)
        folderImage = UIImageView(image: UIImage(named: "folder"))
                
        contentView.addSubview(titleLabel)
        contentView.addSubview(folderImage)
        
        folderImage.snp.makeConstraints { (make) in
            make.height.width.equalTo(30)
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.left.equalTo(folderImage.snp.right).offset(10)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
            
        
    }
    
    private func setUpData() {
        titleLabel.text = model.name
        folderImage.isHidden = !model.isFolder
    }
}
