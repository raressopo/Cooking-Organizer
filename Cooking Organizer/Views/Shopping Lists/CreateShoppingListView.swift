//
//  CreateShoppingListView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 26/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class CreateShoppingListView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var listNameTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    
    var invalidName: (() -> Void)?
    var creationFailed: (() -> Void)?
    
    var oldName: String?
    var changeMode = false
    
    var shoppingLists: [ShoppingList]? {
        return UsersManager.shared.currentLoggedInUser?.shoppingListsArray ?? nil
    }
    
    init(inChangeMode changeMode: Bool = false, withName name: String? = nil, frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        
        listNameTextField.text = name
        oldName = name
        self.changeMode = changeMode
        
        createButton.setTitle(changeMode ? "Change" : "Create", for: .normal)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("CreateShoppingListView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    @IBAction func dismissViewPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func createPressed(_ sender: Any) {
        guard let listName = listNameTextField.text, !listName.isEmpty else {
            invalidName?()
            
            return
        }
        
        if let lists = shoppingLists {
            let existingListName = lists.first(where: { $0.name == listName})
            
            if existingListName != nil {
                invalidName?()
                
                return
            }
        }
        
        if changeMode, let oldName = oldName, let newName = listNameTextField.text, oldName != newName {
            UserDataManager.shared.changeShoppingListName(listName: oldName, withNewName: newName) {
                self.removeFromSuperview()
            } failure: {
                self.creationFailed?()
                
                self.removeFromSuperview()
            }
        } else {
            UserDataManager.shared.createShoppingList(withName: listName, andValues: ["name": listName]) {
                self.removeFromSuperview()
            } failure: {
                self.creationFailed?()
                
                self.removeFromSuperview()
            }
        }
    }
}