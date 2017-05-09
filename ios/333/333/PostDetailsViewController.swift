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
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var sendViewBottomConstraint: NSLayoutConstraint!

    //Variables
    var delegate: FeedViewController?
    
    @IBAction func refreshPost(_ sender: Any) {
        Networking.getComments(post_id: post.id) { (comments) in
            self.comments = comments
            self.tableView.reloadData()
            Toaster.makeToastBottom(self.view, "Refreshed!")
        }
    }
    
    
    @IBAction func deletePost(_ sender: Any) {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete your post?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            print("Delete")
            
            Networking.deletePost(post_id: self.post.id, completion: { (posts) in
                self.delegate?.didReturn()
                self.navigationController?.popViewController(animated: true)
            })
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in
            print("Cancel")
        })
        
        present(alert, animated: true)
    }
    
    
    //Variables
    var post: Post!
    var comments: [Comment]?
    
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
        
        replyTextField.delegate = self
        
        if (post.user_id == UIDevice.current.identifierForVendor!.uuidString) {
            // should be able to delete post.
            deleteButton.isHidden = false
            deleteButton.isEnabled = true
        }
        else {
            // don't show button, don't be able to delete post.
            deleteButton.isHidden = true
            deleteButton.isEnabled = false
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
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
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            
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

            cell.opImageView.isHidden = comment.user_id != post.user_id

            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            
            return cell
        }
    }

    @IBAction func onTouchSend(_ sender: Any) {
        let text = replyTextField.text
        let user_id = UIDevice.current.identifierForVendor!.uuidString

        Networking.createComment(text: text!, user_id: user_id, post_id: post!.id)
        replyTextField.text = nil
        replyTextField.resignFirstResponder()
        
        Networking.getComments(post_id: post.id) { (comments) in
            self.comments = comments
            self.tableView.reloadData()
        }
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.sendViewBottomConstraint.constant = keyboardSize.height
            self.view.layoutIfNeeded()
        }
    }

    func keyboardWillHide(notification: Notification) {
        self.sendViewBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
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

