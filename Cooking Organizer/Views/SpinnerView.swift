//
//  SpinnerView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 10/11/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class SpinnerView: UIView {
    let spinner = UIActivityIndicatorView(style: .large)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .lightGray
        self.layer.opacity = 0.4
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        
        addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
