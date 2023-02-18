//
//  CookingDatesView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 01/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol CookingDatesViewDelegate: AnyObject {
    func cokingDatesChanged(withDates dates: [String])
}

class CookingDatesView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var containerView: UIView! {
        didSet {
            self.containerView.layer.cornerRadius = 8.0
        }
    }
    
    @IBOutlet weak var datesTableView: UITableView! {
        didSet {
            self.datesTableView.clipsToBounds = true
            self.datesTableView.layer.cornerRadius = 8.0
            self.datesTableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            self.datesTableView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        }
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            self.cancelButton.setTitle("Done", for: .normal)
            self.cancelButton.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
            self.cancelButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Regular", size: 18.0)
        }
    }
    @IBOutlet weak var addButton: UIButton! {
        didSet {
            self.addButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Bold", size: 18.0)
            self.addButton.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
        }
    }
    
    @IBOutlet weak var buttonsStackView: UIStackView! {
        didSet {
            self.buttonsStackView.clipsToBounds = true
            self.buttonsStackView.layer.cornerRadius = 8.0
            self.buttonsStackView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            self.buttonsStackView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        }
    }
    
    weak var delegate: CookingDatesViewDelegate?
    
    var dates = [String]()
    
    // MARK: - Initializers
    init(withFrame frame: CGRect, andCookingDates cookingDates: [String]) {
        dates = cookingDates
        
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CookingDatesView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        
        datesTableView.delegate = self
        datesTableView.dataSource = self
        
        datesTableView.isEditing = true
    }
    
    private func displayDatePickerView() {
        let datePickerView = LastCookDatePickerView()
        
        datePickerView.neverCookedButton.removeFromSuperview()
        datePickerView.delegate = self
        
        contentView.addSubview(datePickerView)
        
        datePickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([datePickerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0.0),
                                     datePickerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0),
                                     datePickerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0.0),
                                     datePickerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0)])
    }
    
    @IBAction func editOrSavePressed(_ sender: Any) {
        delegate?.cokingDatesChanged(withDates: dates)
            
        removeFromSuperview()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func addDatePressed(_ sender: Any) {
        displayDatePickerView()
    }
    
    @IBAction func backgroundButtonPressed(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @objc func addDateEditModePressed() {
        displayDatePickerView()
    }
}

extension CookingDatesView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var date = String()
        
        date = dates[indexPath.row]
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "dateCell")
        
        cell.textLabel?.text = date
        cell.textLabel?.font = UIFont(name: "Proxima Nova Alt Regular", size: 16.0)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dates.remove(at: indexPath.row)
            
            delegate?.cokingDatesChanged(withDates: dates)
            
            datesTableView.reloadData()
        }
    }
}

extension CookingDatesView: LastCookDatePickerViewDelegate {
    func didSelectLastCookDate(date: Date?) {
        if let cookingDate = date, !dates.contains(UtilsManager.shared.dateFormatter.string(from: cookingDate)) {
            dates.append(UtilsManager.shared.dateFormatter.string(from: cookingDate))
            
            delegate?.cokingDatesChanged(withDates: dates)
            
            datesTableView.reloadData()
        }
    }
}
