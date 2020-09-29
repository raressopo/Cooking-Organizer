//
//  AlertManager.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 20/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class AlertManager: NSObject {
    class func showAlertWithTitleMessageAndOKButton(onPresenter presenter: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        presenter.present(alert, animated: true)
    }
    
    class func showAlertWithTitleMessageCancelButtonAndCutomButtonAndHandler(onPresenter presenter: UIViewController,
                                                                             title: String,
                                                                             message: String,
                                                                             customButtonTitle: String,
                                                                             customButtonHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: customButtonTitle, style: .default, handler: customButtonHandler))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        presenter.present(alert, animated: true)
    }
    
    class func showDiscardAndSaveAlert(onPresenter presenter: UIViewController,
                                       withTitle title: String,
                                       message: String,
                                       discardButtonHandler: ((UIAlertAction) -> Void)?,
                                       saveButtonHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Discard", style: .default, handler: discardButtonHandler))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: saveButtonHandler))
        
        presenter.present(alert, animated: true)
    }
}
