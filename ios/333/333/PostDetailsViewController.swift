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
    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var upvotesCountLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var replyCountLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var noCommentsLabel: UIView!
    
    //Variables
    var post: Post!
    var comments: [Comment]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load comments
        Networking.getComments(post_id: post.id) { (comments) in
            self.comments = comments
            self.commentsTableView.reloadData()
        }

        // Do any additional setup after loading the view.
        
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        replyTextField.delegate = self
        replyTextField.textColor = UIColor.lightGray
        
        //Set post properties
        captionLabel.text = post.text
        replyCountLabel.text = "\(post.numComments)"
        
        if (post.numComments != 0) { noCommentsLabel.isHidden = true }
        
        upvotesCountLabel.text = "\(post.numUpvotes)"
        timeStampLabel.text = post.dateString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = comments?.count
        {
            noCommentsLabel.isHidden = (count != 0)
            return count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "replyTableViewCell") as! ReplyTableViewCell
        
        let comment = comments![(comments?.count)!-indexPath.row-1]
        
        //Set cell properties
        cell.captionLabel.text = comment.text
        
        return cell
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
            replyTextField.text = ""
            replyTextField.textColor = UIColor.black
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if replyTextField.text == "" {
            replyTextField.text = "Reply..."
            replyTextField.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func onTouchSend(_ sender: Any) {
        let text = replyTextField.text
        let user_id = UIDevice.current.identifierForVendor!.uuidString
        
        if replyTextField.textColor == UIColor.black {
            Networking.createComment(text: text!, user_id: user_id, post_id: post!.id)
        }
        
        replyTextField.text = "Reply..."
        replyTextField.textColor = UIColor.lightGray
        
        Networking.getComments(post_id: post.id) { (comments) in
            self.comments = comments
            self.commentsTableView.reloadData()
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
