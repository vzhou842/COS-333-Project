//
//  PostTableViewCell.swift
//  333
//
//  Created by Jose Rodriguez on 4/2/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit
import SDWebImage

class PostTableViewCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var postCaptionLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var numVotesLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    
    //Variables
    var post: Post?
    var didVote: Bool = false
    
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
        
        // Set this cell's properties
        postCaptionLabel.text = post.text
        repliesLabel.text = "\(post.numComments) Replies"
        numVotesLabel.text = "\(post.numUpvotes)"
        timestampLabel.text = post.dateString
        if let image_url = post.imageUrl {
            postImageView.sd_setImage(with: URL(string: image_url), completed: { (img: UIImage?, e: Error?, _: SDImageCacheType, _: URL?) in
                if let image = img {
                    self.postImageViewHeightConstraint.constant = self.postImageView.frame.size.width * image.size.height / image.size.width
                    self.setNeedsUpdateConstraints()
                } else {
                    print("Failed to set image" + e.debugDescription)
                }
            })
        } else {
            postImageViewHeightConstraint.constant = 0
            self.setNeedsUpdateConstraints()
        }
    }
    
    @IBAction func upvote(_ sender: Any) {
        let user_id = UIDevice.current.identifierForVendor!.uuidString
        let object_id = post!.id
        let up = true
        
        Networking.createVote(user_id: user_id, object_id: object_id, up: up, completion: {() in
            if (self.didVote){
                self.numVotesLabel.text = "\(Int(self.numVotesLabel.text!)!-1)"
                self.didVote = false
                self.upButton.setImage(UIImage(named: "upvote"), for: .normal)
            } else {
                self.numVotesLabel.text = "\(Int(self.numVotesLabel.text!)!+1)"
                self.didVote = true
                self.upButton.setImage(UIImage(named: "upvoteFilled"), for: .normal)
            }
        })
    }

    @IBAction func downvote(_ sender: Any) {
        let user_id = UIDevice.current.identifierForVendor!.uuidString
        let object_id = post!.id
        let up = false
        
        Networking.createVote(user_id: user_id, object_id: object_id, up: up, completion: {() in
            if (self.didVote){
                self.numVotesLabel.text = "\(Int(self.numVotesLabel.text!)!+1)"
                self.didVote = false
                self.downButton.setImage(UIImage(named: "downvote"), for: .normal)
            }
            else {
                self.numVotesLabel.text = "\(Int(self.numVotesLabel.text!)!-1)"
                self.didVote = true
                self.downButton.setImage(UIImage(named: "downvoteFilled"), for: .normal)
            }
        })
    }
    
    
}
