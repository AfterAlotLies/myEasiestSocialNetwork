//
//  FeedViewController.swift
//  InstaCloneFirebase
//
//  Created by Vyacheslav on 06.11.2023.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import SDWebImage

class FeedViewController: ViewController, UITableViewDelegate {

    @IBOutlet private weak var tableView: UITableView!
    
    private var userEmailsArray = [String]()
    private var userCommentArray = [String]()
    private var likeArray = [Int]()
    private var imageArray = [String]()
    private var documentIDArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        getDataFromFirestore()
    }
}

// MARK: - TableViewDataSource
extension FeedViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userEmailsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! myCell
        cell.userNameLabel.text = userEmailsArray[indexPath.row]
        cell.commentLabel.text = userCommentArray[indexPath.row]
        cell.likeLabel.text = String(likeArray[indexPath.row])
        //эт под который позволяет по юрл загружать картинку сюда
        cell.userImage.sd_setImage(with: URL(string: imageArray[indexPath.row]))
        cell.documentIdLabel.text = documentIDArray[indexPath.row]
        return cell
    }
}

// MARK: - getting data from Firestore
private extension FeedViewController {
    
    func getDataFromFirestore() {

        //опять сущность firestore
        let firestoreDatabase = Firestore.firestore()
        //указатель на определенную коллекцию, которая была ранее создана
        //снэпшот слушатель - метод который позволяет в реал тайме получить обновленные данные из бд
        //то есть нет надобности обновлять страницу, слушатель запрос отправляет в бд и получает от туда все только что добавленные
        //допустим данные и поэтому он в реал тайме обновляет стр сам
        firestoreDatabase.collection("Posts").order(by: "date", descending: true).addSnapshotListener { QuerySnapshot, Error in
            if Error != nil {
                self.alertMessage(titleAlert: "Error", alertMessage: Error?.localizedDescription ?? "Error")
            } else {
                //точная проверка что в нашей бд че то есть и она не пустая
                if QuerySnapshot?.isEmpty != true && QuerySnapshot != nil{
                    self.userEmailsArray.removeAll(keepingCapacity: false)
                    self.userCommentArray.removeAll(keepingCapacity: false)
                    self.likeArray.removeAll(keepingCapacity: false)
                    self.imageArray.removeAll(keepingCapacity: false)
                    self.documentIDArray.removeAll(keepingCapacity: false)
                    //берется словарь и по каждому значение прогоняется кастинг переменных с вытаскиванием данных из дб
                    for document in QuerySnapshot!.documents {
                        let documentID = document.documentID
                        self.documentIDArray.append(documentID)
                        
                        if let userPost = document.get("userPost") as? String {
                            self.userEmailsArray.append(userPost)
                        }
                        if let postComment = document.get("postComment") as? String {
                            self.userCommentArray.append(postComment)
                        }
                        if let countOfLikes = document.get("likes") as? Int {
                            self.likeArray.append(countOfLikes)
                        }
                        if let imageUrl = document.get("imageUrl") as? String {
                            self.imageArray.append(imageUrl)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
}
