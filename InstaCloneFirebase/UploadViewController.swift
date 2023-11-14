//
//  UploadViewController.swift
//  InstaCloneFirebase
//
//  Created by Vyacheslav on 06.11.2023.
//

import UIKit
import Firebase
import FirebaseFirestore


class UploadViewController: UIViewController {
    
    @IBOutlet private weak var textUploadField: UITextField!
    @IBOutlet private weak var imageUploadField: UIImageView!
    @IBOutlet private weak var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageUploadField.isUserInteractionEnabled = true
        uploadButton.isUserInteractionEnabled = false
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(getImage))
        imageUploadField.addGestureRecognizer(imageTap)
    }
}

// MARK: - imagePickerControllerDelegate + NavigationControllerDelegate
extension UploadViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc
    func getImage() {
        let pickerImage = UIImagePickerController()
        pickerImage.delegate = self
        pickerImage.sourceType = .photoLibrary
        pickerImage.allowsEditing = true
        present(pickerImage, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageUploadField.image = info[.originalImage] as? UIImage
        uploadButton.isUserInteractionEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - uploading to Firebase
private extension UploadViewController {
    
    @IBAction func uploadButton(_ sender: Any) {
        //создание хранилища
        let storage = Storage.storage()
        //объект для взаимодействия с хранилищем бд
        let storageReference = storage.reference()
        //указатель на папку, так работает с каждой, просто указать несколько детей для объекта, если там еще есть папки
        let mediaFolder = storageReference.child("media")
        //каст фотки с сжатием
        if let data = imageUploadField.image?.jpegData(compressionQuality: 0.5) {
            //создание уникального названия для каждой картинки
            let uuid = UUID().uuidString
            //непосредственное присваивание новому объекту (mediaObject) путь в папку (mediaFolder) с уникальным названием и форматов джпег
            let mediaObject = mediaFolder.child("\(uuid).jpg")
            //здесь добавление этого объекта (картинки, которую кастовали) в облачное хранилище по пути, который указан в mediaObject
            mediaObject.putData(data) { metadata, error in
                //очевидно если ошибка
                if error != nil {
                    self.alertMessage(alertTittle: "Error", alertMessage: error?.localizedDescription ?? "Something go wrong")
                } else {
                    //если ошибка не выскачила и все ок то
                    //получение юрл куда добавляется данное фото
                    mediaObject.downloadURL { URL, Error in
                        if Error == nil {
                            //получение юрл как String
                            let mediaUrl = URL?.absoluteString
                            self.alertMessage(alertTittle: "Success", alertMessage: "Image has been uploaded")

                            //добавление в Firestore(бд)
                            //DATABASE
                            let firestoreDatabase = Firestore.firestore()
                            var firestoreReference : DocumentReference? = nil
                            
                            let firestorePost = ["imageUrl" : mediaUrl!, "userPost" : Auth.auth().currentUser!.email!, "postComment" : self.textUploadField.text!, "date" : FieldValue.serverTimestamp(), "likes" : 0] as [String: Any]
                            //создание новой коллекции в дбшке и добавление туда словаря, который выше, в котором все наши компоненты, которые мы создавали ранее
                            firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { Error in
                                if Error != nil {
                                    self.alertMessage(alertTittle: "Error", alertMessage: Error?.localizedDescription ?? "Error")
                                } else {
                                    self.imageUploadField.image = UIImage(named: "upload")
                                    self.textUploadField.text = ""
                                    self.tabBarController?.selectedIndex = 0 //индексы вкладок на таббаре
                                    
                                }
                            })
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Alert Message
private extension UploadViewController {
    
    func alertMessage(alertTittle : String, alertMessage : String) {
        let alert = UIAlertController(title: alertTittle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
}
