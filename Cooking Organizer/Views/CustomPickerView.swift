//
//  UnitPickerView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 17/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol UnitPickerViewDelegate: AnyObject {
    func didSelectUnit(unit: String)
}

protocol CookingTimePickerViewDelegate: AnyObject {
    func didSelectTime(hours: Int, minutes: Int)
}

protocol DificultyPickerViewDelegate: AnyObject {
    func didSelectDificulty(dificulty: String)
}

protocol LastCookDatePickerViewDelegate: AnyObject {
    func didSelectLastCookDate(date: Date?)
}

protocol SelectDatePickerViewDelegate: AnyObject {
    func didSelectDate(date: Date?, forStartDate startDate: Bool)
}

class CustomPickerView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var dismissUnitViewButton: UIButton!
    @IBOutlet weak var picker: UIPickerView! {
        didSet {
            self.picker.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        }
    }
    @IBOutlet weak var datePicker: UIDatePicker! {
        didSet {
            self.datePicker.clipsToBounds = true
            self.datePicker.layer.cornerRadius = 8.0
            self.datePicker.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            self.datePicker.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        }
    }
    @IBOutlet weak var buttonsStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsStackView: UIStackView! {
        didSet {
            self.buttonsStackView.clipsToBounds = true
            self.buttonsStackView.layer.cornerRadius = 8.0
            self.buttonsStackView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            self.buttonsStackView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        }
    }
    
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
    weak var delegate: UnitPickerViewDelegate?
    
    override func commonInit() {
        super.commonInit()
        
        picker.isHidden = false
        
        picker.delegate = self
        picker.dataSource = self
        picker.layer.cornerRadius = 8.0
    }
}

extension UnitPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Units.allCases.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            delegate?.didSelectUnit(unit: Units.allCases[row - 1].rawValue)
            
            removeFromSuperview()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Proxima Nova Alt Regular", size: 21.0)
            pickerLabel?.textAlignment = .center
        }
        
        var title = ""
        
        if row == 0 {
            title = "Select a unit:"
        } else {
            title = Units.allCases[row - 1].rawValue
        }
        
        pickerLabel?.text = title

        return pickerLabel!
    }
}

// MARK: - Cooking Time Picker View

class CookingTimePickerView: CustomPickerView {
    weak var delegate: CookingTimePickerViewDelegate?
    
    var hoursSelected: Int? {
        didSet {
            if let hours = self.hoursSelected {
                self.picker.selectRow(hours + 1, inComponent: 0, animated: true)
            }
        }
    }
    
    var minutesSelected: Int? {
        didSet {
            if let minutes = self.minutesSelected {
                self.picker.selectRow(minutes + 1, inComponent: 2, animated: true)
            }
        }
    }
    
    override func commonInit() {
        super.commonInit()
        
        picker.isHidden = false
        
        picker.delegate = self
        picker.dataSource = self
        
        self.picker.clipsToBounds = true
        self.picker.layer.cornerRadius = 8.0
        self.picker.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        setupSaveButton()
    }
    
    // MARK: - Private Helpers
    
    private func setupSaveButton() {
        let saveButton = UIButton()
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(UIColor.hexStringToUIColor(hex: "#B46617"), for: .normal)
        saveButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Bold", size: 18.0)
        
        saveButton.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        saveButton.clipsToBounds = true
        saveButton.layer.cornerRadius = 8.0
        saveButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        self.contentView.addSubview(saveButton)
        
        NSLayoutConstraint.activate([saveButton.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 0.0),
                                     saveButton.heightAnchor.constraint(equalToConstant: 40.0),
                                     saveButton.widthAnchor.constraint(equalToConstant: picker.frame.width),
                                     saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0.0)])
        
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
    }
    
    // MARK: - Selectors
    
    @objc func savePressed() {
        let hours = picker.selectedRow(inComponent: 0) == 0 ? 0 : picker.selectedRow(inComponent: 0) - 1
        let minutes = picker.selectedRow(inComponent: 2) == 0 ? 0 : picker.selectedRow(inComponent: 2) - 1
        
        delegate?.didSelectTime(hours: hours, minutes: minutes)
        
        removeFromSuperview()
    }
}

extension CookingTimePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 25
        } else if component == 2 {
            return 61
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            return 100
        case 1:
            return 30
        case 2:
            return 100
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0, 2:
            if row == 0 {
                pickerView.selectRow(1, inComponent: component, animated: true)
            }
        default:
            break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Proxima Nova Alt Regular", size: 21.0)
            pickerLabel?.textAlignment = .center
        }
        
        var title = ""
        switch component {
        case 0:
            if row == 0 {
                title = "hours"
            } else if row < 11 {
                title = "0\(row - 1)"
            } else {
                title = "\(row - 1)"
            }
        case 1:
            title = ":"
        case 2:
            if row == 0 {
                title = "minutes"
            } else if row < 11 {
                title = "0\(row - 1)"
            } else {
                title = "\(row - 1)"
            }
        default:
            break
        }
        
        pickerLabel?.text = title

        return pickerLabel!
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
        
        self.picker.isHidden = false
        self.picker.clipsToBounds = true
        self.picker.layer.cornerRadius = 8.0
    }
}

extension DificultyPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dificulties.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != 0 {
            delegate?.didSelectDificulty(dificulty: dificulties[row - 1])
        }
        
        removeFromSuperview()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Proxima Nova Alt Regular", size: 21.0)
            pickerLabel?.textAlignment = .center
        }
        
        var title = ""
        if row == 0 {
            title = "Dificulties:"
        } else {
            title = dificulties[row - 1]
        }
        
        pickerLabel?.text = title

        return pickerLabel!
    }
}

// MARK: - Last Cooking Date Picker View

class LastCookDatePickerView: CustomPickerView {
    weak var delegate: LastCookDatePickerViewDelegate?
    
    var neverCookedButton = UIButton()
    
    override func commonInit() {
        super.commonInit()
        
        datePicker.isHidden = false
        buttonsStackView.isHidden = false
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.axis = .vertical
        
        setupSaveButton()
        setupNeverCookedButton()
    }
    
    // MARK: - Private Helpers
    
    private func setupSaveButton() {
        let saveButton = UIButton()
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.setTitleColor(UIColor.hexStringToUIColor(hex: "#B46617"), for: .normal)
        saveButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Bold", size: 20.0)
        
        saveButton.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        saveButton.setTitle("Save", for: .normal)
        
        buttonsStackView.addArrangedSubview(saveButton)
        
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
    }
    
    private func setupNeverCookedButton() {
        neverCookedButton.translatesAutoresizingMaskIntoConstraints = false
        
        neverCookedButton.setTitle("Never Cooked", for: .normal)
        neverCookedButton.setTitleColor(UIColor.hexStringToUIColor(hex: "#B46617"), for: .normal)
        neverCookedButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Regular", size: 20.0)
        
        neverCookedButton.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        
        buttonsStackView.addArrangedSubview(neverCookedButton)
        self.buttonsStackViewHeightConstraint.constant = 100.0
        
        neverCookedButton.addTarget(self, action: #selector(neverCookedPressed), for: .touchUpInside)
    }
    
    // MARK: - Selectors
    
    @objc func savePressed() {
        delegate?.didSelectLastCookDate(date: datePicker.date)
        
        removeFromSuperview()
    }
    
    @objc func neverCookedPressed() {
        delegate?.didSelectLastCookDate(date: nil)
        
        removeFromSuperview()
    }
}

class SelectDatePickerView: CustomPickerView, UIPickerViewDelegate {
    weak var delegate: SelectDatePickerViewDelegate?
    
    var isStartDate = false
    
    override func commonInit() {
        super.commonInit()
        
        datePicker.isHidden = false
        buttonsStackView.isHidden = false
        buttonsStackView.distribution = .fillEqually
        
        setupSaveButton()
    }
    
    // MARK: - Private Helpers
    
    private func setupSaveButton() {
        let saveButton = UIButton()
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.primaryButtonSetup()
        
        buttonsStackView.addArrangedSubview(saveButton)
        
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
    }
    
    // MARK: - Selectors
    
    @objc func savePressed() {
        delegate?.didSelectDate(date: datePicker.date, forStartDate: isStartDate)
        
        removeFromSuperview()
    }
}
