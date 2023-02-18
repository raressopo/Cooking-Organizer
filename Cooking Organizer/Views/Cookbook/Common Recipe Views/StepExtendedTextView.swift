//
//  StepExtendedTextView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 16.03.2021.
//  Copyright © 2021 Rares Soponar. All rights reserved.
//

import UIKit

protocol StepExtendedTextViewDelegate: AnyObject {
    func stepDetailsSaved(withText text: String?, atIndex index: Int)
    func stepDetailsCanceled()
}

class StepExtendedTextView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var containerView: UIView! {
        didSet {
            self.containerView.layer.cornerRadius = 10.0
        }
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            self.cancelButton.setTitleColor(UIColor.hexStringToUIColor(hex: "#C17A03"), for: .normal)
            self.cancelButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Light", size: 19.0)
        }
    }
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            self.saveButton.setTitleColor(UIColor.hexStringToUIColor(hex: "#C17A03"), for: .normal)
            self.saveButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Bold", size: 19.0)
        }
    }
    @IBOutlet weak var stepDetailsTextView: UITextView! {
        didSet {
            self.stepDetailsTextView.font = UIFont(name: "Proxima Nova Alt Light", size: 15.0)
        }
    }
    
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @IBAction func dismissViewPressed(_ sender: Any) {
        self.delegate?.stepDetailsCanceled()
        
        removeFromSuperview()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.delegate?.stepDetailsCanceled()
        
        removeFromSuperview()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        delegate?.stepDetailsSaved(withText: stepDetailsTextView.text, atIndex: index)
        
        removeFromSuperview()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.topConstraint.constant = 55
            self.bottomConstraint.constant = keyboardRectangle.height + 55
        }
    }
    
    @objc func keyboardWillHide() {
        self.topConstraint.constant = 260
        self.bottomConstraint.constant = 260
    }
}
