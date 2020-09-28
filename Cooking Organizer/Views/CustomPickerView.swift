//
//  UnitPickerView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 17/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol UnitPickerViewDelegate: class {
    func didSelectUnit(unit: String)
}

protocol CookingTimePickerViewDelegate: class {
    func didSelectTime(hours: Int, minutes: Int)
}

protocol DificultyPickerViewDelegate: class {
    func didSelectDificulty(dificulty: String)
}

protocol LastCookDatePickerViewDelegate: class {
    func didSelectLastCookDate(date: Date)
}

class CustomPickerView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var dismissUnitViewButton: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    // MARK: - Public Helpers
    
    func commonInit() {
        Bundle.main.loadNibNamed("CustomPickerView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        
        picker.isHidden = true
        datePicker.isHidden = true
    }
    
    // MARK: - IBActions
    
    @IBAction func dismissUnitViewPressed(_ sender: Any) {
        removeFromSuperview()
    }
}

// MARK: - Unit Picker View

class UnitPickerView: CustomPickerView {
    private let volumeUnits = ["tsp", "tbsp", "cup", "cups", "ml", "L"]
    private let massAndWeightUnits = ["lb", "oz", "mg", "g", "kg"]
    
    private var allUnits = [String]()
    
    weak var delegate: UnitPickerViewDelegate?
    
    override func commonInit() {
        super.commonInit()
        
        picker.isHidden = false
        
        picker.delegate = self
        picker.dataSource = self
        
        allUnits = volumeUnits + massAndWeightUnits
    }
}

// MARK: - Unit Picker View - Picker View Delegates and DataSource

extension UnitPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allUnits.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allUnits[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.didSelectUnit(unit: allUnits[row])
        
        removeFromSuperview()
    }
}

// MARK: - Cooking Time Picker View

class CookingTimePickerView: CustomPickerView {
    weak var delegate: CookingTimePickerViewDelegate?
    
    override func commonInit() {
        super.commonInit()
        
        picker.isHidden = false
        
        picker.delegate = self
        picker.dataSource = self
    }
    
    // MARK: - Private Helpers
    
    private func setupSaveButton() {
        let saveButton = UIButton()
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(UIColor.systemBlue, for: .normal)
        saveButton.backgroundColor = UIColor.white
        
        self.contentView.addSubview(saveButton)
        
        NSLayoutConstraint.activate([saveButton.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 0.0),
                                     saveButton.heightAnchor.constraint(equalToConstant: 40.0),
                                     saveButton.widthAnchor.constraint(equalToConstant: picker.frame.width),
                                     saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0.0)])
        
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
    }
    
    // MARK: - Selectors
    
    @objc func savePressed() {
        delegate?.didSelectTime(hours: picker.selectedRow(inComponent: 0), minutes: picker.selectedRow(inComponent: 2))
        
        removeFromSuperview()
    }
}

// MARK: - Cooking Time Picker View - Picker View Delegate and DataSource

extension CookingTimePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 24
        } else if component == 2 {
            return 60
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0, 2:
            return "\(row)"
        case 1:
            return "h"
        case 3:
            return "min"
        default:
            return nil
        }
    }
}

// MARK: - Dificulty Picker View

class DificultyPickerView: CustomPickerView {
    weak var delegate: DificultyPickerViewDelegate?
    
    private let dificulties = ["Easy", "Medium", "Hard"]
    
    override func commonInit() {
        super.commonInit()
        
        picker.delegate = self
        picker.dataSource = self
        
        picker.isHidden = false
    }
}

// MARK: - Dificulty Picker View - Picker View Delegate and DataSource

extension DificultyPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dificulties.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dificulties[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.didSelectDificulty(dificulty: dificulties[row])
        
        removeFromSuperview()
    }
}

// MARK: - Last Cooking Date Picker View

class LastCookDatePickerView: CustomPickerView {
    weak var delegate: LastCookDatePickerViewDelegate?
    
    override func commonInit() {
        super.commonInit()
        
        datePicker.isHidden = false
    }
    
    // MARK: - Private Helpers
    
    private func setupSaveButton() {
        let saveButton = UIButton()
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(UIColor.systemBlue, for: .normal)
        saveButton.backgroundColor = UIColor.white
        
        datePicker.backgroundColor = UIColor.white
        
        self.contentView.addSubview(saveButton)
        
        NSLayoutConstraint.activate([saveButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 0.0),
                                     saveButton.heightAnchor.constraint(equalToConstant: 40.0),
                                     saveButton.widthAnchor.constraint(equalToConstant: datePicker.frame.width),
                                     saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0.0)])
        
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
    }
    
    // MARK: - Selectors
    
    @objc func savePressed() {
        delegate?.didSelectLastCookDate(date: datePicker.date)
        
        removeFromSuperview()
    }
}
