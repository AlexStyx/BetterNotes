//
//  AuthoriztionViewController.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 07.02.2021.
//

import UIKit
import Firebase

class AuthoriztionViewController: UIViewController {
    
    @IBOutlet weak var errorConditionLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ref: DatabaseReference!
    
    let firebase = Firebase()
    lazy var firebaseAuthentication = firebase.fireBaseAuthentication
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorConditionLabel.alpha = 0
        firebaseAuthentication.addStateDidChangeListener { [weak self ](auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: "notesSegue", sender: nil)
            }
        }
        ref = Database.database().reference(withPath: "users")
    }
    
    @IBAction func unwindSegueToAuth(segue: UIStoryboardSegue) {
        
    }
    
    func disaplyErrorMessage(withText text: String) {
        errorConditionLabel.text = text
        
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) {
            [weak self] in
            self?.errorConditionLabel.alpha = 1
        } completion: { [weak self ]complete in
            self?.errorConditionLabel.alpha = 0
        }

    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            disaplyErrorMessage(withText: "Incorrect data")
            return
        }
        firebaseAuthentication.signIn(withEmail: email, password: password) { [weak self] (data, error) in
            if error != nil {
                self?.disaplyErrorMessage(withText: "Error occured")
                return
            }
            
            if data != nil {
                self?.performSegue(withIdentifier: "notesSegue", sender: nil)
                return
            }
            self?.disaplyErrorMessage(withText: "No such user")
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            disaplyErrorMessage(withText: "Incorrect data")
            return
        }
        firebaseAuthentication.createUser(withEmail: email, password: password) { [weak self] (data, error) in
            guard data != nil, error == nil else {
                print(error?.localizedDescription ?? "ERROR with no description")
                return
            }
            let userRef = self?.ref.child(String((data?.user.uid)!))
            userRef?.setValue(["email": data?.user.email])
        
        }

    }
    
    
}
