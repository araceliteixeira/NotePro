//
//  NoteListTableVC.swift
//  NotePro
//
//  Created by Araceli Teixeira on 28/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

class NoteListTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    private let searchCellNameAndId: String = String(describing: SearchViewCell.self)
    private let sortCellNameAndId: String = String(describing: SortViewCell.self)
    private let noteCellNameAndId: String = String(describing: NoteViewCell.self)
    public var subject: Subject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: searchCellNameAndId, bundle: nil), forCellReuseIdentifier: searchCellNameAndId)
        tableView.register(UINib(nibName: sortCellNameAndId, bundle: nil), forCellReuseIdentifier: sortCellNameAndId)
        tableView.register(UINib(nibName: noteCellNameAndId, bundle: nil), forCellReuseIdentifier: noteCellNameAndId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTableList),
                                               name: NSNotification.Name(rawValue: kNOTIFICATION_NOTE_LIST_CHANGED), object: nil)
        
        CoreFacade.shared.fetchNoteList(subject)
    }
    
    @objc func updateTableList() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.contentOffset = .zero
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this note?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
                CoreFacade.shared.deleteNote(CoreFacade.shared.notes[indexPath.row]);
                CoreFacade.shared.fetchNoteList(self.subject)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.performSegue(withIdentifier: "addNote", sender: indexPath)
        }
        edit.backgroundColor = UIColor.blue
        
        return [delete, edit]
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreFacade.shared.notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let rawCell = tableView.dequeueReusableCell(withIdentifier: searchCellNameAndId, for: indexPath)
            
            guard let cell = rawCell as? SearchViewCell else {
                print("Error while retrieving cell \(searchCellNameAndId)")
                return rawCell
            }
            cell.setLabel("Search by Title:")
            cell.setCallback { (text) in
                CoreFacade.shared.searchNoteByTitle(text, self.subject)
            }
            
            return cell
        case 1:
            let rawCell = tableView.dequeueReusableCell(withIdentifier: searchCellNameAndId, for: indexPath)
            
            guard let cell = rawCell as? SearchViewCell else {
                print("Error while retrieving cell \(searchCellNameAndId)")
                return rawCell
            }
            cell.setLabel("Search by Keyword:")
            cell.setCallback { (text) in
                CoreFacade.shared.searchNoteByKeyword(text, self.subject)
            }
            
            return cell
        default:
            let rawCell = tableView.dequeueReusableCell(withIdentifier: noteCellNameAndId, for: indexPath)
            
            guard let cell = rawCell as? NoteViewCell else {
                print("Error while retrieving cell \(noteCellNameAndId)")
                return rawCell
            }
            cell.configureCell(CoreFacade.shared.notes[indexPath.row])
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showNoteDetails", sender: tableView.cellForRow(at: indexPath))
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "showNoteDetails":
            guard let destination = segue.destination as? NoteVC else {
                print("Destination isn't a NoteVC")
                return
            }
            guard let index = tableView.indexPathForSelectedRow?.row else {
                print("Invalid index")
                return
            }
            destination.note = CoreFacade.shared.notes[index]
        default:
            break
        }
    }
    
    @IBAction func unwindToNoteList(sender: UIStoryboardSegue) {
        guard let destination = sender.source as? NoteVC else {
            print("Destination isn't a NoteVC")
            return
        }
        guard let subjectFromNote = destination.note?.subject else {
            print("Invalid Subject")
            return
        }
        subject = subjectFromNote
    }
}
