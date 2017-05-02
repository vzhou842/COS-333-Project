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
    
    //Variables
    var comment: Comment?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onTouchUpvote(_ sender: Any) {
        if let comment = comment {
            let user_id = UIDevice.current.identifierForVendor!.uuidString
            let object_id = comment.comment_id
            let up = true
            
            Networking.createVote(user_id: user_id, object_id: object_id, up: up, completion: {() in
                self.votesCountLabel.text = "\(Int(self.votesCountLabel.text!)!+1)"
            })
        }
    }
    
    @IBAction func onTouchDownvote(_ sender: Any) {
        print(comment?.text)
        print(captionLabel.text ?? "damn")
        if let comment = comment {
            let user_id = UIDevice.current.identifierForVendor!.uuidString
            let object_id = comment.comment_id
            let up = false
            
            Networking.createVote(user_id: user_id, object_id: object_id, up: up, completion: {() in
                self.votesCountLabel.text = "\(Int(self.votesCountLabel.text!)!-1)"
            })
        }
    }
}
