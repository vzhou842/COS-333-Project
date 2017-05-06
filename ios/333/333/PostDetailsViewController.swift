//
//  PostDetailsViewController.swift
//  333
//
//  Created by Jose Rodriguez on 4/6/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit

class PostDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    //Outlets
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var upvotesCountLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var replyCountLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var noCommentsLabel: UIView!
    
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    
    //Variables
    var post: Post!
    var comments: [Comment]?
    var keyboardHeight = 300 as CGFloat
    let defaultReply = "Reply ..."
    
    var didUpvote: Bool = false
    var didDownvote: Bool = false
    
    var lat: Float!
    var long: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load comments
        Networking.getComments(post_id: post.id) { (comments) in
            self.comments = comments
            self.commentsTableView.reloadData()
            
            if (comments.count != 0) { self.noCommentsLabel.isHidden = true }
            else { self.commentsTableView.isHidden = true }
        }

        // Do any additional setup after loading the view.
        
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        replyTextField.delegate = self
        replyTextField.textColor = UIColor.lightGray
        
        //Set post properties
        captionLabel.text = post.text
        replyCountLabel.text = "\(post.numComments)"
        
        upvotesCountLabel.text = "\(post.numUpvotes)"
        timeStampLabel.text = post.dateString
        
        view.bringSubview(toFront: replyView)
        replyView.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "replyTableViewCell") as! ReplyTableViewCell
        
        let comment = comments![(comments?.count)!-indexPath.row-1]
        
        //Set cell properties
        cell.captionLabel.text = comment.text
        cell.votesCountLabel.text = "\(comment.numUpvotes)"
        cell.comment = comment
        
        cell.lat = self.lat
        cell.long = self.long
        
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        replyTextField.text = ""
        replyTextField.textColor = UIColor.black
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if replyTextField.text == "" {
            replyTextField.text = defaultReply
            replyTextField.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func onTouchSend(_ sender: Any) {
        let text = replyTextField.text
        let user_id = UIDevice.current.identifierForVendor!.uuidString
        
        if replyTextField.textColor == UIColor.black {
            Networking.createComment(text: text!, user_id: user_id, post_id: post!.id)
        }
        
        replyTextField.text = defaultReply
        replyTextField.textColor = UIColor.lightGray
        
        Networking.getComments(post_id: post.id) { (comments) in
            self.comments = comments
            self.commentsTableView.reloadData()
        }
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTouchUpvote(_ sender: Any) {
        let user_id = UIDevice.current.identifierForVendor!.uuidString
        let object_id = post!.id
        let up = true
        
        Networking.createVote(lat: lat, long: long, user_id: user_id, object_id: object_id, up: up, completion: {() in
            if (self.didUpvote){
                self.upvotesCountLabel.text = "\(Int(self.upvotesCountLabel.text!)!-1)"
                self.didUpvote = false
                self.upButton.setImage(UIImage(named: "upvote"), for: .normal)
            } else if (self.didDownvote) {
                self.upvotesCountLabel.text = "\(Int(self.upvotesCountLabel.text!)!+2)"
                self.didUpvote = true
                self.didDownvote = false
                self.downButton.setImage(UIImage(named: "downvote"), for: .normal)
                self.upButton.setImage(UIImage(named: "upvoteFilled"), for: .normal)
            } else {
                self.upvotesCountLabel.text = "\(Int(self.upvotesCountLabel.text!)!+1)"
                self.didUpvote = true
                self.upButton.setImage(UIImage(named: "upvoteFilled"), for: .normal)
            }
        })
    }
    
    @IBAction func onTouchDownvote(_ sender: Any) {
        let user_id = UIDevice.current.identifierForVendor!.uuidString
        let object_id = post!.id
        let up = false
        
        Networking.createVote(lat: lat, long: long, user_id: user_id, object_id: object_id, up: up, completion: {() in
            if (self.didUpvote){
                self.upvotesCountLabel.text = "\(Int(self.upvotesCountLabel.text!)!-2)"
                self.didUpvote = false
                self.didDownvote = true
                self.upButton.setImage(UIImage(named: "upvote"), for: .normal)
                self.downButton.setImage(UIImage(named: "downvoteFilled"), for: .normal)
            } else if (self.didDownvote) {
                self.upvotesCountLabel.text = "\(Int(self.upvotesCountLabel.text!)!+1)"
                self.didDownvote = false
                self.downButton.setImage(UIImage(named: "downvote"), for: .normal)
            } else {
                self.upvotesCountLabel.text = "\(Int(self.upvotesCountLabel.text!)!-1)"
                self.didDownvote = true
                self.downButton.setImage(UIImage(named: "downvoteFilled"), for: .normal)
            }
        })
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if replyView.frame.origin.y == (self.view.frame.height - replyView.frame.height){
                replyView.frame.origin.y -= keyboardSize.height
            }
        }        
    }
    
//    func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            keyboardHeight = keyboardSize.height
//            print(keyboardHeight)
//        }
////        replyView.frame.origin.y -= (keyboardHeight)
//        replyView.frame.origin.y = self.view.frame.height - keyboardHeight - replyView.frame.height
////        self.view.frame.origin.y -= (keyboardHeight + replyView.frame.height)
//        print("Show Keyboard")
//        print("TOT HEIGHT: \(self.view.frame.height)")
//        print("ReplyView Origin: \(replyView.frame.origin.y)")
//        print("ReplyView Height: \(replyView.frame.height)")
//        print("Keyboard Height: \(keyboardHeight)")
//    }
    
    func keyboardWillHide(notification: Notification) {
        replyView.frame.origin.y = self.view.frame.height - replyView.frame.height
//        self.view.frame.origin.y += (keyboardHeight - replyView.frame.height)
        print("Hide Keyboard")
        print("ReplyView Origin: \(replyView.frame.origin.y)")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
