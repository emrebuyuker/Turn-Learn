//
//  SaveViewController.swift
//  Turn Learn
//
//  Created by Emre BÜYÜKER on 29.11.2020.
//

import UIKit
import FirebaseFirestore

class SaveViewController: UIViewController {

    @IBOutlet private weak var firstWordTextField: UITextField!
    @IBOutlet private weak var secondWordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
        let uuid = UUID().uuidString
        let firestoreDatabase = Firestore.firestore()
        let firestorePost = ["firstWord" : self.firstWordTextField.text!, "secondWord": self.secondWordTextField.text!] as [String : Any]
        
        firestoreDatabase.collection("WORDS").document(uuid).setData(firestorePost, merge: true, completion: { [weak self] (error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription , preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okButton)
                self?.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Successful", message: "Kayıt başarılı bir şekilde yapıldı." , preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self?.firstWordTextField.text = ""
                    self?.secondWordTextField.text = ""
                })
                alert.addAction(okButton)
                self?.present(alert, animated: true, completion: nil)
            }
        })
    }
}
