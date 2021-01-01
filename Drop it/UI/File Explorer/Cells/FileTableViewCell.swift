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
        didSet {
            setUpData()
        }
    }
    
    var titleLabel: UILabel!
    var dateLabel: UILabel!
    var thumbnailImage: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.model = DropboxFile(id: "", cursor: "", name: "", path: "", description: "", isFolder: false, dateModified: nil)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpCell() {
        titleLabel = UILabel(frame: .zero)
        dateLabel = UILabel(frame: .zero)
        thumbnailImage = UIImageView(image: UIImage(named: "file"))
        
        dateLabel.font = dateLabel.font.withSize(12)
        dateLabel.textColor = .gray
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(thumbnailImage)
        
        thumbnailImage.snp.makeConstraints { (make) in
            make.height.width.equalTo(30)
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.left.equalTo(thumbnailImage.snp.right).offset(10)
            make.right.equalToSuperview()
            make.centerY.equalTo(20)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.left.equalTo(thumbnailImage.snp.right).offset(10)
            make.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
    }
    
    private func setUpData() {
        titleLabel.text = model.name
        
        if let thumbnail = model.thumbnail {
            thumbnailImage.image = thumbnail
        } else {
            thumbnailImage.image = UIImage(named: "file")
        }
    
        if let date = model.dateModified {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YY/MM/dd"
            dateLabel.text = "Date modified: " + dateFormatter.string(from: date)
        }
    }
}
