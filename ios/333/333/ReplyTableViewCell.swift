//
//  ReplyTableViewCell.swift
//  333
//
//  Created by Jose Rodriguez on 4/6/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit

class ReplyTableViewCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var votesCountLabel: UILabel!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var opImageView: UIImageView!

    //Variables
    var comment: Comment?

    var didUpvote: Bool?
    var didDownvote: Bool?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func onTouchUpvote(_ sender: Any) {
        if let comment = comment {
            let user_id = UIDevice.current.identifierForVendor!.uuidString
            let object_id = comment.comment_id
            let up = true
            
            Networking.createVote(lat: Location.sharedInstance.lat, long: Location.sharedInstance.long, user_id: user_id, object_id: object_id, up: up, completion: {(success) in
                if (!success) {
                    return
                }
                if (self.didUpvote)!{
                    self.votesCountLabel.text = "\(Int(self.votesCountLabel.text!)!-1)"
                    self.didUpvote = false
                    self.upButton.setImage(UIImage(named: "upvote"), for: .normal)
                } else if (self.didDownvote)! {
                    self.votesCountLabel.text = "\(Int(self.votesCountLabel.text!)!+2)"
                    self.didUpvote = true
                    self.didDownvote = false
                    self.downButton.setImage(UIImage(named: "downvote"), for: .normal)
                    self.upButton.setImage(UIImage(named: "upvoteFilled"), for: .normal)
                } else {
                    self.votesCountLabel.text = "\(Int(self.votesCountLabel.text!)!+1)"
                    self.didUpvote = true
                    self.upButton.setImage(UIImage(named: "upvoteFilled"), for: .normal)
                }
                
                let defaults = UserDefaults.standard
                defaults.set(self.didUpvote, forKey: "up"+comment.comment_id)
                defaults.set(self.didDownvote, forKey: "down"+comment.comment_id)
                defaults.synchronize()
            })
        }
    }
    
    @IBAction func onTouchDownvote(_ sender: Any) {
        if let comment = comment {
            let user_id = UIDevice.current.identifierForVendor!.uuidString
            let object_id = comment.comment_id
            let up = false
            
            Networking.createVote(lat: Location.sharedInstance.lat, long: Location.sharedInstance.long, user_id: user_id, object_id: object_id, up: up, completion: {(success) in
                if (!success) {
                    return
                }
                if (self.didUpvote)!{
                    self.votesCountLabel.text = "\(Int(self.votesCountLabel.text!)!-2)"
                    self.didUpvote = false
                    self.didDownvote = true
                    self.upButton.setImage(UIImage(named: "upvote"), for: .normal)
                    self.downButton.setImage(UIImage(named: "downvoteFilled"), for: .normal)
                } else if (self.didDownvote)! {
                    self.votesCountLabel.text = "\(Int(self.votesCountLabel.text!)!+1)"
                    self.didDownvote = false
                    self.downButton.setImage(UIImage(named: "downvote"), for: .normal)
                } else {
                    self.votesCountLabel.text = "\(Int(self.votesCountLabel.text!)!-1)"
                    self.didDownvote = true
                    self.downButton.setImage(UIImage(named: "downvoteFilled"), for: .normal)
                }
                
                let defaults = UserDefaults.standard
                defaults.set(self.didUpvote, forKey: "up"+comment.comment_id)
                defaults.set(self.didDownvote, forKey: "down"+comment.comment_id)
                defaults.synchronize()
            })
        }
    }
}
