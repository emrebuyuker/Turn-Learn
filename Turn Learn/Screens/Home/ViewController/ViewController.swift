//
//  ViewController.swift
//  Turn Learn
//
//  Created by Emre BÜYÜKER on 29.11.2020.
//

import UIKit
import FirebaseFirestore
import CodableFirebase

class ViewController: UIViewController {

    @IBOutlet private weak var wordView: UIView!
    @IBOutlet private weak var wordLabel: UILabel!
    @IBOutlet private weak var okeyButton: UIButton!
    @IBOutlet private weak var doMemorizeButton: UIButton!
    @IBOutlet private weak var doAgainButton: UIButton!
    
    private var wordsResponseModel: [WordsResponseModel] = []
    private var selectRow: Int = 0
    private var isShowSecondWord: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.wordView.layer.shadowColor = UIColor.black.cgColor
        self.wordView.layer.shadowOpacity = 0.8
        self.wordView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.wordView.layer.shadowRadius = 2
        
        self.getDataFirestore()
    }
    
    func getDataFirestore() {
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("WORDS").getDocuments { [weak self] (documents, error) in
            documents?.documents.forEach({ (document) in
                do {
                    var model = try FirestoreDecoder().decode(WordsResponseModel.self, from: document.data())
                    model.documentId = document.documentID
                    self?.wordsResponseModel.append(model)
                } catch {
                    print(error)
                }
            })
            if self?.wordsResponseModel.count ?? 0 > 0 {
                self?.wordLabel.text = self?.wordsResponseModel[0].firstWord
            }
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if(event?.subtype == UIEvent.EventSubtype.motionShake) {
            let vc = SaveViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func nextButtonClick(_ sender: Any) {
        if self.wordsResponseModel.count == 0 {
            return
        }
        self.isShowSecondWord = false
        if self.selectRow >= self.wordsResponseModel.count - 1 {
            self.selectRow = 0
        } else {
            self.selectRow += 1
        }
        self.wordLabel.text = self.wordsResponseModel[self.selectRow].firstWord
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        if self.wordsResponseModel.count == 0 {
            return
        }
        self.isShowSecondWord = false
        if self.selectRow == 0 {
            self.selectRow = self.wordsResponseModel.count - 1
        } else {
            self.selectRow -= 1
        }
        self.wordLabel.text = self.wordsResponseModel[self.selectRow].firstWord
    }
    
    @IBAction func turnButtonClick(_ sender: Any) {
        if self.wordsResponseModel.count == 0 {
            return
        }
        if self.isShowSecondWord {
            self.wordLabel.text = self.wordsResponseModel[self.selectRow].firstWord
            self.isShowSecondWord = false
        } else {
            self.wordLabel.text = self.wordsResponseModel[self.selectRow].secondWord
            self.isShowSecondWord = true
        }
    }
    
    
    @IBAction func okeyButtonClick(_ sender: Any) {
        if self.wordsResponseModel.count == 0 {
            return
        }
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("WORDS").document(self.wordsResponseModel[self.selectRow].documentId ?? "").delete {[weak self] (error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription , preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okButton)
                self?.present(alert, animated: true, completion: nil)
            } else {
                
                self?.memoriseFirebase()
            }
        }
    }
    
    func memoriseFirebase() {
        let uuid = UUID().uuidString
        let firestoreDatabase = Firestore.firestore()
        let firestorePost = ["firstWord" : self.wordsResponseModel[selectRow].firstWord , "secondWord": self.wordsResponseModel[selectRow].secondWord] as [String : Any]
        
        firestoreDatabase.collection("MEMORİSES").document(uuid).setData(firestorePost, merge: true, completion: { [weak self] (error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription , preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okButton)
                self?.present(alert, animated: true, completion: nil)
            } else {
                self?.wordsResponseModel.remove(at: self?.selectRow ?? 0)
                if self?.selectRow ?? 0 >= self?.wordsResponseModel.count ?? 0 - 1 {
                    if self?.wordsResponseModel.count ?? 0 > 0 {
                        self?.wordLabel.text = self?.wordsResponseModel[0].firstWord
                    } else {
                        self?.wordLabel.text = ""
                    }
                } else {
                    self?.wordLabel.text = self?.wordsResponseModel[self?.selectRow ?? 0].firstWord
                }
                let alert = UIAlertController(title: "Successful", message: "Tebrikler kelimeyi ezberlediniz." , preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okButton)
                self?.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func doAgainButtonClick(_ sender: Any) {
        self.wordsResponseModel.removeAll()
        self.doMemorizeButton.isHidden = false
        self.okeyButton.isHidden = true
        self.doAgainButton.isHidden = true
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("MEMORİSES").getDocuments { [weak self] (documents, error) in
            documents?.documents.forEach({ (document) in
                do {
                    var model = try FirestoreDecoder().decode(WordsResponseModel.self, from: document.data())
                    model.documentId = document.documentID
                    self?.wordsResponseModel.append(model)
                } catch {
                    print(error)
                }
            })
            if self?.wordsResponseModel.count ?? 0 > 0 {
                self?.wordLabel.text = self?.wordsResponseModel[0].firstWord
            } else {
                self?.wordLabel.text = ""
            }
        }
    }
    
    @IBAction func doMemorizeButtonClick(_ sender: Any) {
        self.wordsResponseModel.removeAll()
        self.doMemorizeButton.isHidden = true
        self.okeyButton.isHidden = false
        self.doAgainButton.isHidden = false
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("WORDS").getDocuments { [weak self] (documents, error) in
            documents?.documents.forEach({ (document) in
                do {
                    var model = try FirestoreDecoder().decode(WordsResponseModel.self, from: document.data())
                    model.documentId = document.documentID
                    self?.wordsResponseModel.append(model)
                } catch {
                    print(error)
                }
            })
            if self?.wordsResponseModel.count ?? 0 > 0 {
                self?.wordLabel.text = self?.wordsResponseModel[0].firstWord
            } else {
                self?.wordLabel.text = ""
            }
        }
    }
    
}
