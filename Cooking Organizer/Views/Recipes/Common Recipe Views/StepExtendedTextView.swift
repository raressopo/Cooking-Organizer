//
//  StepExtendedTextView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 16.03.2021.
//  Copyright © 2021 Rares Soponar. All rights reserved.
//

import UIKit

protocol StepExtendedTextViewDelegate: class {
    func stepDetailsSaved(withText text: String?, atIndex index: Int)
}

class StepExtendedTextView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var stepDetailsTextView: UITextView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var index: Int = -1
    
    weak var delegate: StepExtendedTextViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("StepExtendedTextView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    @IBAction func dismissViewPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        delegate?.stepDetailsSaved(withText: stepDetailsTextView.text, atIndex: index)
        
        removeFromSuperview()
    }
}
