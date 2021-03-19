//
//  FoldersTableViewController.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 17.02.2021.
//

import UIKit
import Firebase

class FoldersTableViewController: UIViewController {
    
    var client: Client!
    var ref: DatabaseReference!
    var folders = Array<Folder>()
    var selectedFolder = "Main"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        view.backgroundColor = .black
        view.addSubview(foldersLabel)
        layoutLabel()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FolderCell.self, forCellReuseIdentifier: "folderCell")
        layoutTableView()
        view.addSubview(toolbar)
        layoutToolbar()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        client = Client(user: currentUser)
        ref = Database.database().reference().child("clients").child(String(client.uid)).child("folders")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.observe(.value) { [weak self] snapshot in
            var _folders = Array<Folder>()
            for item in snapshot.children {
                let folder = Folder(snapshot: item as! DataSnapshot)
                _folders.append(folder)
            }
            self?.folders = _folders
            self?.tableView.reloadData()
        }
    }
    
    //MARK: - Setup UI
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        return tableView
    }()
    
    private func layoutTableView() {
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: foldersLabel.bottomAnchor).isActive = true
    }
    
    private let foldersLabel: UILabel = {
        let label = UILabel()
        label.text = "Folders"
        label.tintColor = .white
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func layoutLabel() {
        foldersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        foldersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
    }
    
    @objc private func addFolderTapped() {
        let alertController = UIAlertController(title: "Add Folder", message: "Please type the name of your folder", preferredStyle: .alert)
        let addFolderAction = UIAlertAction(title: "Add", style: .default) { [weak self]_ in
            guard let textFieild = alertController.textFields?.first else { return }
            let folderRef = self?.ref.childByAutoId()
            let folderName = textFieild.text
            let folder = Folder(name: folderName!, userId: (self?.client.uid)!, uniqueId: (folderRef?.key)!)
            folderRef?.setValue(folder.convertToDictionary())
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        alertController.addAction(addFolderAction)
        alertController.addTextField { (textField) in
            textField.placeholder = "Folder Name"
        }
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Setup searchController
    let searchController = UISearchController(searchResultsController: nil)
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.view.translatesAutoresizingMaskIntoConstraints = false
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let addFolderIte = UIBarButtonItem(image: UIImage(systemName: "plus.rectangle.on.folder"), style: .done, target: self, action: #selector(addFolderTapped))
        toolbar.tintColor = .systemYellow
        toolbar.setItems([flexibleItem, addFolderIte, flexibleItem], animated: true)
        return toolbar
    }()
    
    private func layoutToolbar() {
        toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
}

// MARK: - Segue business
extension FoldersTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let notesTableViewController = segue.destination as? NotesTableViewController else { return }
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let folder = folders[indexPath.row]
        let folderId = folder.uniqueId
        notesTableViewController.folderId = folderId!
    }
}

// MARK: - UISearchResultsUpdating
extension FoldersTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension FoldersTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "folderCell", for: indexPath) as! FolderCell
        let folder = folders[indexPath.row]
        let folderName = folder.name
        cell.textLabel?.text = folderName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "choseFolderSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let folder = folders[indexPath.row]
            folder.reference?.removeValue()
        }
    }
}
