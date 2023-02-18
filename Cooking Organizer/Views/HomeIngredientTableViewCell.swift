//
//  HomeIngredientTableViewCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 28/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class HomeIngredientTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel! {
        didSet {
            self.name.font = UIFont(name: "Proxima Nova Alt Bold", size: 20.0)
        }
    }
    
    @IBOutlet weak var expirationDate: UILabel! {
        didSet {
            self.expirationDate.font = UIFont(name: "Proxima Nova Alt Light", size: 14.0)
        }
    }
    
    @IBOutlet weak var quantityAndUnit: UILabel! {
        didSet {
            self.quantityAndUnit.font = UIFont(name: "Proxima Nova Alt Light", size: 16.0)
        }
    }
    
    @IBOutlet weak var mainContainerView: UIView! {
        didSet {
            self.mainContainerView.layer.cornerRadius = 16.0
        }
    }
}
