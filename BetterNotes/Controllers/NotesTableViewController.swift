//
//  NotesTableViewController.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 06.02.2021.
//

import UIKit
import AKSideMenu
import Firebase

class NotesTableViewController: UIViewController {
        
    var client: Client!
    var ref: DatabaseReference!
    var notes = Array<Note>()
    var folderId = "-MVIF5BU_LqHmbk6M-Vw"
    
    @IBOutlet weak var tableView: UITableView!
    
    let transition = SideMenuAnimator(duration: 0.8) // init custom transition
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .done, target: self, action: #selector(goToFolders))
        leftBarButtonItem.tintColor = .systemYellow
        navigationItem.leftBarButtonItem = leftBarButtonItem
        setupSearchController()
        view.addSubview(toolbar)
        layoutToolBar()
        guard let currentUser = Auth.auth().currentUser else { return }
        client = Client(user: currentUser)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref = Database.database().reference().child("clients").child(String(client.uid)).child("folders").child(folderId).child("notes")
        updateUI()
    }
    
    // MARK: - Swipe business
    @IBAction func swipedRight(_ sender: UISwipeGestureRecognizer) {
        goToFolders()
    }
    
    @objc private func goToFolders() {
        self.performSegue(withIdentifier: "foldersSegue", sender: nil)
    }
    
    // MARK: - Setup UI
    let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: nil, action: #selector(createNewNote))
        addBarButtonItem.tintColor = .systemYellow
        toolbar.setItems([flexibleItem, addBarButtonItem], animated: true)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    private func layoutToolBar() {
        toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    @objc func createNewNote() {
        self.performSegue(withIdentifier: "createNoteSegue", sender: nil)
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
}

// MARK: - UITableViewDelegate and UITableViewDataSource
extension NotesTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteCell
        let note = notes[indexPath.row]
        cell.noteHeadtitleLabel.text = note.headtitle
        cell.noteTextLabel.text = note.text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = notes[indexPath.row]
            note.referecne?.removeValue()
        }
    }
}

// MARK: - Segues business

extension NotesTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "foldersSegue" {
            view.mask = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            view.mask?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            guard let foldersViewController = segue.destination as? FoldersTableViewController else { return }
            foldersViewController.modalPresentationStyle = .overFullScreen
            foldersViewController.transitioningDelegate = self
        }
        
        if segue.identifier == "openNoteSegue" {
            guard let noteViewController = segue.destination as? NoteViewController else { return }
            noteViewController.open = true
            let indexPath = tableView.indexPathForSelectedRow
            let folderId = self.folderId
            let note = notes[indexPath!.row]
            noteViewController.folderId = folderId
            noteViewController.note = note
    
        }
        
        if segue.identifier == "createNoteSegue" {
            guard let noteViewController = segue.destination as? NoteViewController else { return }
            let folderId = self.folderId
            noteViewController.folderId = folderId
            noteViewController.open = false
        }
    }
    
    @IBAction func unwindToNotes(segue: UIStoryboardSegue) {
        view.mask = nil
    }
    
}


// MARK: - UIViewControllerTransitioningDelegate
extension NotesTableViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        updateUI()
        return transition
    }
}

// MARK: - UISearchResultsUpdating
extension NotesTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension NotesTableViewController {
    private func updateUI() {
        ref = Database.database().reference().child("clients").child(String(client.uid)).child("folders").child(folderId).child("notes")
        ref.observe(.value) { [weak self] snaphot in
            var _notes = Array<Note>()
            for item in snaphot.children {
                let note = Note(snapshot: item as! DataSnapshot)
                _notes.append(note)
            }
            self?.notes = _notes
            self?.tableView.reloadData()
        }
    }
}
