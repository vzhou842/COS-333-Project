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
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBAction func refreshPost(_ sender: Any) {
        Networking.getComments(post_id: post.id) { (comments) in
            self.comments = comments
            self.commentsTableView.reloadData()
            Toaster.makeToastBottom(self.view, "Refreshed!")
        }
    }
    
    //Variables
    var post: Post!
    var comments: [Comment]?
    var keyboardHeight = 300 as CGFloat
    let defaultReply = "Reply ..."
    
    var didUpvote: Bool = false
    var didDownvote: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let defaults = UserDefaults.standard
        didUpvote = defaults.bool(forKey: "up"+post.id)
        didDownvote = defaults.bool(forKey: "down"+post.id)
        
        if (didUpvote) {
            self.upButton.setImage(UIImage(named: "upvoteFilled"), for: .normal)
        }
        else if (didDownvote) {
            self.downButton.setImage(UIImage(named: "downvoteFilled"), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        didUpvote = defaults.bool(forKey: "up"+post.id)
        didDownvote = defaults.bool(forKey: "down"+post.id)
        
        if (didUpvote) {
            self.upButton.setImage(UIImage(named: "upvoteFilled"), for: .normal)
        }
        else {
            self.upButton.setImage(UIImage(named: "upvote"), for: .normal)
        }
        if (didDownvote) {
            self.downButton.setImage(UIImage(named: "downvoteFilled"), for: .normal)
        }
        else {
            self.downButton.setImage(UIImage(named: "downvote"), for: .normal)
        }
        
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        replyTextField.delegate = self
        replyTextField.textColor = UIColor.lightGray
        
        //Set post properties
        captionLabel.text = post.text
        replyCountLabel.text = "\(post.numComments) comments"
        if (post.numComments == 1)
        {replyCountLabel.text = "\(post.numComments) comment"}
        
        cityLabel.text = post.city
        
        upvotesCountLabel.text = "\(post.numUpvotes)"
        let timeInterval = post.date.timeIntervalSinceNow
        timeStampLabel.text = "\(Utils.formatDate(-timeInterval)) ago"
        
        view.bringSubview(toFront: replyView)
        replyView.isUserInteractionEnabled = true
        
        // Load comments
        Networking.getComments(post_id: post.id) { (comments) in
            self.comments = comments
            self.commentsTableView.reloadData()
            
            if (comments.count != 0) { self.noCommentsLabel.isHidden = true }
            else { self.commentsTableView.isHidden = true }
        }

        // Do any additional setup after loading the view.
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
        
        let defaults = UserDefaults.standard
        
        //Set cell properties
        cell.captionLabel.text = comment.text
        cell.votesCountLabel.text = "\(comment.numUpvotes)"
        cell.comment = comment
        
        let timeIntervalComment = comment.date.timeIntervalSinceNow
        cell.timestampLabel.text = "\(Utils.formatDate(-timeIntervalComment)) ago"
        
        cell.didUpvote = defaults.bool(forKey: "up"+comment.comment_id)
        cell.didDownvote = defaults.bool(forKey: "down"+comment.comment_id)
        
        if (cell.didUpvote)! {
            cell.upButton.setImage(UIImage(named: "upvoteFilled"), for: .normal)
        }
        else {
            cell.upButton.setImage(UIImage(named: "upvote"), for: .normal)
        }
        if (cell.didDownvote)! {
            cell.downButton.setImage(UIImage(named: "downvoteFilled"), for: .normal)
        }
        else {
            cell.downButton.setImage(UIImage(named: "downvote"), for: .normal)
        }
        
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
        
        noCommentsLabel.isHidden = true
        commentsTableView.isHidden = false
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTouchUpvote(_ sender: Any) {
        let user_id = UIDevice.current.identifierForVendor!.uuidString
        let object_id = post!.id
        let up = true
        
        Networking.createVote(lat: Location.sharedInstance.lat, long: Location.sharedInstance.long, user_id: user_id, object_id: object_id, up: up, completion: {(success) in
            if (!success) {
                return
            }
            if (self.didUpvote){
                self.upvotesCountLabel.text = "\(Int(self.upvotesCountLabel.text!)!-1)"
                self.didUpvote = false
                self.upButton.setImage(UIImage(named: "upvote"), for: .normal)
                self.post?.numUpvotes -= 1
            } else if (self.didDownvote) {
                self.upvotesCountLabel.text = "\(Int(self.upvotesCountLabel.text!)!+2)"
                self.didUpvote = true
                self.didDownvote = false
                self.downButton.setImage(UIImage(named: "downvote"), for: .normal)
                self.upButton.setImage(UIImage(named: "upvoteFilled"), for: .normal)
                self.post?.numUpvotes += 2
            } else {
                self.upvotesCountLabel.text = "\(Int(self.upvotesCountLabel.text!)!+1)"
                self.didUpvote = true
                self.upButton.setImage(UIImage(named: "upvoteFilled"), for: .normal)
                self.post?.numUpvotes += 1
            }
            
            print(self.didDownvote)
            print(self.didUpvote)
            let defaults = UserDefaults.standard
            defaults.set(self.didUpvote, forKey: "up"+self.post.id)
            defaults.set(self.didDownvote, forKey: "down"+self.post.id)
            defaults.synchronize()
            
            print(self.post.numUpvotes)
        })
    }
    
    @IBAction func onTouchDownvote(_ sender: Any) {
        let user_id = UIDevice.current.identifierForVendor!.uuidString
        let object_id = post!.id
        let up = false
        
        Networking.createVote(lat: Location.sharedInstance.lat, long: Location.sharedInstance.long, user_id: user_id, object_id: object_id, up: up, completion: {(success) in
            if (!success) {
                return
            }
            if (self.didUpvote){
                self.upvotesCountLabel.text = "\(Int(self.upvotesCountLabel.text!)!-2)"
                self.didUpvote = false
                self.didDownvote = true
                self.upButton.setImage(UIImage(named: "upvote"), for: .normal)
                self.downButton.setImage(UIImage(named: "downvoteFilled"), for: .normal)
                self.post?.numUpvotes -= 2
            } else if (self.didDownvote) {
                self.upvotesCountLabel.text = "\(Int(self.upvotesCountLabel.text!)!+1)"
                self.didDownvote = false
                self.downButton.setImage(UIImage(named: "downvote"), for: .normal)
                self.post?.numUpvotes += 1
            } else {
                self.upvotesCountLabel.text = "\(Int(self.upvotesCountLabel.text!)!-1)"
                self.didDownvote = true
                self.downButton.setImage(UIImage(named: "downvoteFilled"), for: .normal)
                self.post?.numUpvotes -= 1
            }
            
            print(self.didDownvote)
            print(self.didUpvote)
            let defaults = UserDefaults.standard
            defaults.set(self.didUpvote, forKey: "up"+self.post.id)
            defaults.set(self.didDownvote, forKey: "down"+self.post.id)
            defaults.synchronize()
            
            print(self.post.numUpvotes)
        })
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

