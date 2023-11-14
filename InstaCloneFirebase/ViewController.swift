//
//  ViewController.swift
//  InstaCloneFirebase
//
//  Created by Vyacheslav on 06.11.2023.
//


//в SceneDelegate лежат строки кода, которые проверяют, авторизовался ли уже пользователь, чтобы постоянно не авторизовываться, а заходить на главное меню 

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet private weak var passwordText: UITextField!
    @IBOutlet private weak var emailText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

   
}

// MARK: - SignIn + SignUp actions
private extension ViewController {
    
    @IBAction private func signUpClick(_ sender: Any) {
        
        if emailText.text != "" {
            if passwordText.text != "" {
                //создание пользователя за счет методa firebase
                Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { AuthDataResult, Error in
                    if Error != nil {
                        self.alertMessage(titleAlert: "Error", alertMessage: Error?.localizedDescription ?? "Error")
                    } else {
                        self.performSegue(withIdentifier: "toMainView", sender: nil)
                    }
                }
            } else {
                alertMessage(titleAlert: "Error", alertMessage: "Enter your password first")
            }
        } else {
            alertMessage(titleAlert: "Error", alertMessage: "Enter your email first")
        }
    }
    
    @IBAction private func signInClick(_ sender: Any) {
        if emailText.text != "" {
            if passwordText.text != "" {
                //авторизация за счет метода firebase
                Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { AuthDataResult, Error in
                    if Error != nil {
                        self.alertMessage(titleAlert: "Error", alertMessage: Error?.localizedDescription ?? "Error")
                    } else {
                        self.performSegue(withIdentifier: "toMainView", sender: nil)
                    }
                }
            } else {
                alertMessage(titleAlert: "Error", alertMessage: "Enter your password")
            }
        } else {
            alertMessage(titleAlert: "Error", alertMessage: "Enter your email")

        }
    }
}

// MARK: - AlertMessage
extension ViewController {
    
    func alertMessage(titleAlert : String, alertMessage : String) {
        let alert = UIAlertController(title: titleAlert, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
}

