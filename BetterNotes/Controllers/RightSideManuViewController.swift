//
//  ViewController.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 08.02.2021.
//

import UIKit
import Firebase

class RightSideManuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .systemYellow
        view.addSubview(userImageView)
        layoutImageView()
        view.addSubview(signOutButton)
        layoutSignOutButton()
    }
    
    let userImageView: UIImageView = {
        let image = UIImage(systemName: "person.circle")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private func layoutImageView() {
        userImageView.widthAnchor.constraint(equalToConstant: 125).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: 125).isActive = true
        userImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        userImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
    }
    
    let signOutButton = { () -> UIButton in
        let signOutButton = UIButton()
        signOutButton.backgroundColor = .systemGray
        signOutButton.setTitle("Sign out", for: .normal)
        signOutButton.setTitleColor(.systemRed, for: .normal)
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        signOutButton.layer.cornerRadius = 10
        return signOutButton
    }()
    
    private func layoutSignOutButton() {
        let sidePadding: CGFloat = 30
        signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signOutButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        signOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding).isActive = true
        signOutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding).isActive = true
    }
    
    @objc private func signOut() {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "unwindToAuth", sender: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
