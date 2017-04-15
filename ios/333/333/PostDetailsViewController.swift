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
    
    
    //Variables
    var post = Dictionary<String, Any>()
    var comments = [Dictionary<String, Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        replyTextField.delegate = self
        replyTextField.textColor = UIColor.lightGray
        
        //Set post properties
        captionLabel.text = post["text"] as? String
        let numComments = post["num_comments"] as! Int
        replyCountLabel.text = "\(numComments)"
        let numVotes = post["num_upvotes"] as! Int
        upvotesCountLabel.text = "\(numVotes)"
        let timeStamp = post["timestamp"] as! String
        let date = Networking.dateFormatter.date(from: timeStamp)
        timeStampLabel.text = Networking.niceDateFormatter?.string(from: date!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "replyTableViewCell") as! ReplyTableViewCell
        
        let comment = comments[indexPath.row]
        
        //Set cell properties
        cell.captionLabel.text = comment["text"] as! String?
        
        return cell
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if replyTextField.textColor == UIColor.lightGray {
            replyTextField.text = ""
            replyTextField.textColor = UIColor.black
        }
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
        let post_id = post["post_id"] as! String
        
        if replyTextField.textColor == UIColor.black {
            Networking.createComment(text: text!, user_id: user_id, post_id: post_id)
        }
        
        replyTextField.text = "Reply..."
        replyTextField.textColor = UIColor.lightGray
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
