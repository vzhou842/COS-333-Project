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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var replyTextField: UITextField!
    
    @IBAction func refreshPost(_ sender: Any) {
        Networking.getComments(post_id: post.id) { (comments) in
            self.comments = comments
            self.tableView.reloadData()
            Toaster.makeToastBottom(self.view, "Refreshed!")
        }
    }
    
    //Variables
    var post: Post!
    var comments: [Comment]?
    var keyboardHeight = 300 as CGFloat
    let defaultReply = "Reply ..."
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300

        // Load comments
        Networking.getComments(post_id: post.id) { (comments) in
            self.comments = comments
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (comments != nil && comments!.count > 0) {
            return comments!.count + 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            // Post cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: "postTableViewCell") as! PostTableViewCell

            // Configure this cell for its post.
            cell.configureWithPost(self.post)

            return cell
        } else if (indexPath.row == 1 && (comments == nil || comments!.count == 0)) {
            // No Comments Yet cell.
            return tableView.dequeueReusableCell(withIdentifier: "noCommentsCell")!
        } else {
            // Comment cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: "replyTableViewCell") as! ReplyTableViewCell

            let comment = comments![(comments?.count)!-indexPath.row]

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
            self.tableView.reloadData()
        }
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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

