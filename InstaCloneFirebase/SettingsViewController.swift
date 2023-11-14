//
//  SettingsViewController.swift
//  InstaCloneFirebase
//
//  Created by Vyacheslav on 06.11.2023.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction private func logoutClick(_ sender: Any) {
        //для выхода из аккаунта
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toRegForm", sender: nil)
        } catch {
            print("error")
        }
    }

}
