//
//  myCell.swift
//  InstaCloneFirebase
//
//  Created by Vyacheslav on 08.11.2023.
//

import UIKit
import Firebase
import FirebaseFirestore

class myCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var documentIdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

// MARK: - likedButton
private extension myCell  {
    
    @IBAction func likedButton(_ sender: Any) {
        let firestore = Firestore.firestore()
        
        if let likeCount = Int(likeLabel.text!) {
            let likePosts = ["likes" : likeCount + 1] as [String : Any]
            //условное слияние с уже существующим объектом в документе (merge)
            firestore.collection("Posts").document(documentIdLabel.text ?? "Error").setData(likePosts, merge: true)
        }
    }
}
