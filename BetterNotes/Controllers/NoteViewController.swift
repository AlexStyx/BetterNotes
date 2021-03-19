//
//  NewNoteViewController.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 11.02.2021.
//  All rights

import UIKit
import Firebase

class NoteViewController: UIViewController, UITextFieldDelegate {
    
    var ref: DatabaseReference!
    var client: Client!
    var folderId = ""
    var open = false
    var note = Note(headtitle: "", text: "", uniqueId: "", folderName: "")
    
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
//        self.performSegue(withIdentifier: "recorderSegue", sender: nil)
        addPlayer()
    }
    
    @objc private func changeFont() {
        self.performSegue(withIdentifier: "fontsSegue", sender: nil)
    }
    
    @objc private func addPhoto() {
        
    }
    
    private func addPlayer() {
        let player = PlayerView()
        player.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(player)
        player.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        player.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        player.topAnchor.constraint(equalTo: views.last!.bottomAnchor, constant: 10).isActive = true
        views.append(player)
        print(views.count)
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
                let text = noteTextView.text
                let note = Note(headtitle: headtitle!, text: text!, uniqueId: noteRef.key!, folderName: folderId)
                noteRef.setValue(note.convertToDictionary())
                
            }
        }
        
        note = Note(headtitle: "", text: "", uniqueId: "", folderName: "")
    }
}

