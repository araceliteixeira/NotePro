//
//  NoteVC.swift
//  NotePro
//
//  Created by Araceli Teixeira on 02/04/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

class NoteVC: UITableViewController {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var subjectField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    
    let datePickerView: UIDatePicker = UIDatePicker()
    var subjectPickerView: SubjectPickerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        initScreen()
    }
    
    fileprivate func initScreen() {
        setDefaultDate()
    }
    
    fileprivate func setDefaultDate() {
        self.dateField.text = DateUtil.convertDateToString(Date(), .medium, .short)
    }
    
    @IBAction func saveNote(_ sender: UIBarButtonItem) {
        if let title = titleField.text,
           let description = descriptionField.text,
           let subject = subjectPickerView?.selectedSubject,
           let dateTime = dateField.text {
            
            guard let dateTimeToObject = DateUtil.convertStringToDate(dateTime, .medium, .short) else {
                print("Error to parse the date")
                return
            }
            
            let newNote = Note(title, description, subject, dateTimeToObject)
            CoreFacade.shared.saveNote(newNote)
        }
        
    }
    
    
    @IBAction func handleSubjectPicker(_ sender: UITextField) {
        createSubjectPicker(sender)
    }
    
    fileprivate func createSubjectPicker(_ sender: UITextField) {
        subjectPickerView = SubjectPickerView(subjectField: sender)
        sender.inputView = subjectPickerView?.pickerView
        subjectField.inputAccessoryView = createToolBarForSubject()
    }
    
    @IBAction func handleDatePicker(_ sender: UITextField) {
        createDataPicker(sender)
    }
    
    fileprivate func createDataPicker(_ sender: UITextField) {
        datePickerView.datePickerMode = .dateAndTime
        datePickerView.endEditing(true)
        datePickerView.isUserInteractionEnabled = true
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(NoteVC.hangleValueChange), for: .valueChanged)
        dateField.inputAccessoryView = createToolBar()
    }
    
    @objc func hangleValueChange() {
        handleDataPicker()
    }
    
    @objc func hangleValueChangeForSubject(subject: String) {
        subjectField.text = subject
    }
    
    fileprivate func createToolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        toolBar.setItems(createButtons(), animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
    fileprivate func handleDataPicker() {
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateStyle = .medium
        dateTimeFormatter.timeStyle = .short
        dateField.text = DateUtil.convertDateToString(datePickerView.date, .medium, .short)
    }
    
    fileprivate func createButtons() -> [UIBarButtonItem] {
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(NoteVC.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(NoteVC.cancelClick))
        let buttons: [UIBarButtonItem] = [cancelButton, spaceButton, doneButton]
        return buttons
    }
    
    @objc func doneClick() {
        handleDataPicker()
        dateField.resignFirstResponder()
    }
    
    @objc func cancelClick() {
        dateField.resignFirstResponder()
    }
    
    fileprivate func createToolBarForSubject() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        toolBar.setItems(createButtonsForSubject(), animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
    fileprivate func createButtonsForSubject() -> [UIBarButtonItem] {
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(NoteVC.doneClickForSubject))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(NoteVC.cancelClickForSubject))
        let buttons: [UIBarButtonItem] = [cancelButton, spaceButton, doneButton]
        return buttons
    }
    
    @objc func doneClickForSubject() {
        subjectField.resignFirstResponder()
    }
    
    @objc func cancelClickForSubject() {
        subjectField.resignFirstResponder()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class SubjectPickerView: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var subjects: [Subject] = [
        Subject(1, "Travel", UIColor.black, 1),
        Subject(2, "Sports", UIColor.blue, 1),
        Subject(3, "Home", UIColor.red, 1),
        Subject(4, "Work", UIColor.yellow, 1),
        Subject(5, "Study", UIColor.cyan, 1)
    ]
    var pickerView: UIPickerView = UIPickerView()
    var subjectField: UITextField
    var selectedSubject: Subject?
    
    init(subjectField: UITextField) {
        self.subjectField = subjectField
        super.init()
        self.pickerView.endEditing(true)
        self.pickerView.isUserInteractionEnabled = true
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return subjects.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return subjects[row].subject
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.subjectField.text = subjects[row].subject
        self.selectedSubject = subjects[row]
    }
}
