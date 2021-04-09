//
//  NewNoteViewController.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 11.02.2021.
//  All rights

import UIKit
import Firebase
import FirebaseStorage

class NoteViewController: UIViewController, UITextFieldDelegate {
    
    let storage = Storage.storage()
    var storageRef: StorageReference!
    var ref: DatabaseReference!
    var client: Client!
    var folderId = ""
    var open = false
    var paths: Array<URL> = []
    var note = Note(headtitle: "", content: [], uniqueId: "", folderName: "")
    
    let transition = BottomMenuAnimator(duration: 0.8)
    
    var views: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .systemYellow
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideKeyboard))
        navigationItem.rightBarButtonItem = doneBarButtonItem
        addSubviews()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        client = Client(user: currentUser)
        storageRef = storage.reference()
        if !open {
            ref = Database.database().reference().child("clients").child(String(client.uid)).child("folders").child(folderId).child("notes")
        } else {
            ref = Database.database().reference().child("clients").child(String(client.uid)).child("folders").child(folderId).child("notes").child((note.uniqueId!))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if open {
            ref.observe(.value) { [weak self] snapshot in
                self?.note = Note(snapshot: snapshot)
                self?.headtitleTextField.text = self?.note.headtitle
                self?.noteTextView.text = self?.note.text
            }
        }
    }
    
    //MARK: - Swipe business
    
    @IBAction func swipedDown(_ sender: UISwipeGestureRecognizer) {
        hideKeyboard()
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    //MARK: - Setup UI
    let headtitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Headtitle"
        textField.font = UIFont.boldSystemFont(ofSize: 25)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private func layoutHeadtitletextField() {
        headtitleTextField.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        headtitleTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        headtitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).isActive = true
        headtitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).isActive = true
    }
    
    let noteTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private func layoutNoteTextView() {
        noteTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        noteTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        noteTextView.topAnchor.constraint(equalTo: headtitleTextField.bottomAnchor, constant: 1).isActive = true
    }
    
    let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let addAudionNoteAction = UIBarButtonItem(image: UIImage(systemName: "waveform"), style: .done, target: nil, action: #selector(createAudioNote))
        let changeFontAction = UIBarButtonItem(image: UIImage(systemName: "textformat"), style: .done, target: nil, action: #selector(changeFont))
        let addPhotoAction =  UIBarButtonItem(image: UIImage(systemName: "camera"), style: .done, target: nil, action: #selector(addPhoto))
        toolbar.setItems([addAudionNoteAction, flexibleItem, changeFontAction, flexibleItem, addPhotoAction], animated: true)
        toolbar.tintColor = .systemYellow
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    let keyBoardToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let addAudionNoteAction = UIBarButtonItem(image: UIImage(systemName: "waveform"), style: .done, target: nil, action: #selector(createAudioNote))
        let changeFontAction = UIBarButtonItem(image: UIImage(systemName: "textformat"), style: .done, target: nil, action: #selector(changeFont))
        let addPhotoAction =  UIBarButtonItem(image: UIImage(systemName: "camera"), style: .done, target: nil, action: #selector(addPhoto))
        toolbar.setItems([addAudionNoteAction, flexibleItem, changeFontAction, flexibleItem, addPhotoAction], animated: true)
        toolbar.tintColor = .systemYellow
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    private func layoutToolbar() {
        toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    // MARK: - Functions for toolbar
    @objc private func createAudioNote() {
        self.performSegue(withIdentifier: "recorderSegue", sender: nil)
    }
    
    @objc private func changeFont() {
        self.performSegue(withIdentifier: "fontsSegue", sender: nil)
    }
    
    @objc private func addPhoto() {
        
    }
    
    private func addPlayer(url: URL) {
        let player = PlayerView(url: paths.last!)
        player.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(player)
        player.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        player.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -10).isActive = true
        player.topAnchor.constraint(equalTo: views.last!.bottomAnchor, constant: 10).isActive = true
        player.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15).isActive = true
        views.append(player)
    }
    
    private func addTextView(text: String) {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = text
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        guard let lastView = views.last else { return }
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        textView.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 1).isActive = true
        view.addSubview(textView)
        
    }
    
    private func addSubviews() {
        view.addSubview(headtitleTextField)
        layoutHeadtitletextField()
        view.addSubview(noteTextView)
        views.append(noteTextView)
        noteTextView.inputAccessoryView = keyBoardToolbar
        layoutNoteTextView()
        view.addSubview(toolbar)
        layoutToolbar()
    }
}

// MARK: - Segues business
extension NoteViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "recorderSegue" {
            guard let recorderViewController = segue.destination as? RecorderViewController else { return }
            recorderViewController.modalPresentationStyle = .overFullScreen
            recorderViewController.transitioningDelegate = self
            recorderViewController.note = self.note
        }
        
        if segue.identifier == "fontsSegue" {
            print("fonts")
            guard let fontsViewController = segue.destination as? FontsViewController else { return }
            fontsViewController.modalPresentationStyle = .overFullScreen
            fontsViewController.transitioningDelegate = self
        }
        
        view.mask = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.mask?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
    }
    
    @IBAction func unwindToNote(segue: UIStoryboardSegue) {
        view.mask = nil
        guard let sourceVC = segue.source as? RecorderViewController else { return }
        paths = sourceVC.paths
        addPlayer(url: paths.last!)
    }
}


// MARK: - UIViewControllerTransitioningDelegate
extension NoteViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
}

// MARK: - Touches begin
extension NoteViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideKeyboard()
    }
}

extension NoteViewController {
    func saveData() {
        if headtitleTextField.text != "" || (noteTextView.text != "Your Note" && noteTextView.text != "") {
            if open {
                ref.updateChildValues(["headtitle": headtitleTextField.text, "text": noteTextView.text])
            } else {
                let noteRef = ref.childByAutoId()
                let headtitle = headtitleTextField.text
                let content = note.content
                let note = Note(headtitle: headtitle!, content: content!, uniqueId: noteRef.key!, folderName: folderId)
                noteRef.setValue(note.convertToDictionary())
                
            }
        }
        
        note = Note(headtitle: "", content: [], uniqueId: "", folderName: "")
    }
}

//MARK: - Data business
extension NoteViewController {
    private func unpakcContent(content: [Content]) {
        for contentItem in content {
            switch contentItem.contentType {
            case .text(let text): addTextView(text: text)
            case .audio(let path): addPlayer(url: path)
            case .photo(let path): print("add photoView")
            }
        }
    }
    
    private func validateData(content: [Content]) {
        for item in content {
            switch item.contentType {
            case .text(let text): addTextView(text: text)
            case .audio(let url): addPlayer(url: url)
            case .photo(let url): print(url)
            }
        }
    }
    
    private func validateData(views: [UIView]) {
        for item in views{
            switch item {
            case item as? UITextView:
                guard let text = (item as! UITextView).text else { return }
                saveText(text: text)
            case item as? PlayerView:
                guard let path = (item as! PlayerView).url else { return }
                saveAudio(path: path)
            default:
                print("lol")
            }
        }
    }
    
    private func saveText(text: String) {
        
    }
    
    private func saveAudio(path: URL) {
        
    }
}

