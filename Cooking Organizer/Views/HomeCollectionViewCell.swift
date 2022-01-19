//
//  HomeCollectionViewCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 17/01/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(withHomeItem homeItem: HomeItems) {
        titleLabel.text = homeItem.asString
    }
}
