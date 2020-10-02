//
//  CookingDatesView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 01/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol CookingDatesViewDelegate: class {
    func cokingDatesChanged(withDates dates: [String])
}

class CookingDatesView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var datesTableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    weak var delegate: CookingDatesViewDelegate?
    
    var dates = [String]()
    var datesCopy = [String]()
    
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
    }
    
    private func setupAddDateButton() {
        let button = UIButton()
        
        button.setTitle("Add Date", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = editButton.titleLabel?.font
        
        button.addTarget(self, action: #selector(addDatePressed), for: .touchUpInside)
        
        buttonsStackView.addArrangedSubview(button)
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
        if editButton.titleLabel?.text == "Edit" {
            editButton.setTitle("Save", for: .normal)
            
            datesTableView.setEditing(true, animated: true)
            
            datesCopy = dates.map( {$0} )
            
            setupAddDateButton()
            
            datesTableView.reloadData()
        } else {
            delegate?.cokingDatesChanged(withDates: datesCopy)
            
            removeFromSuperview()
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func backgroundButtonPressed(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @objc func addDatePressed() {
        displayDatePickerView()
    }
}

extension CookingDatesView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.isEditing ? datesCopy.count : dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var date = String()
        
        if tableView.isEditing {
            date = datesCopy[indexPath.row]
        } else {
            date = dates[indexPath.row]
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "dateCell")
        
        cell.textLabel?.text = date
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            datesCopy.remove(at: indexPath.row)
            
            datesTableView.reloadData()
        }
    }
}

extension CookingDatesView: LastCookDatePickerViewDelegate {
    func didSelectLastCookDate(date: Date?) {
        if let cookingDate = date {
            datesCopy.append(UtilsManager.shared.dateFormatter.string(from: cookingDate))
            
            datesTableView.reloadData()
        }
    }
}
