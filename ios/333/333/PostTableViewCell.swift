//
//  PostTableViewCell.swift
//  333
//
//  Created by Jose Rodriguez on 4/2/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var postCaptionLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var numVotesLabel: UILabel!
    
    //Variables
    var post: Post?
    var comments = [Dictionary<String, Any>]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithPost(_ post: Post) {
        self.post = post
        
        Networking.getComments(post_id: post.id) { (comments) in
            self.comments = comments
        }
        
        // Set this cell's properties
        self.postCaptionLabel.text = post.text
        self.repliesLabel.text = "\(post.numComments) Replies"
        self.numVotesLabel.text = "\(post.numUpvotes)"
        self.timestampLabel.text = post.dateString
    }
    
    @IBAction func upvote(_ sender: Any) {
        let user_id = UIDevice.current.identifierForVendor!.uuidString
        let object_id = post!.id
        let up = true
        
        Networking.createVote(user_id: user_id, object_id: object_id, up: up)
        //INCREMENT THE NUMBER OF VOTES IF SUCCESSFUL
    }

    @IBAction func downvote(_ sender: Any) {
        let user_id = UIDevice.current.identifierForVendor!.uuidString
        let object_id = post!.id
        let up = false
        
        Networking.createVote(user_id: user_id, object_id: object_id, up: up)
        //DECREMENT THE NUMBER OF VOTES IF SUCCESSFUL
    }
    
    
}
