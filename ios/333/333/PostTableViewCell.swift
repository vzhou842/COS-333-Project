//
//  PostTableViewCell.swift
//  333
//
//  Created by Jose Rodriguez on 4/2/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postCaptionLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        replyButton.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onTouchUpvoteButton(_ sender: Any) {
    }

    @IBAction func onTouchCommentButton(_ sender: Any) {
    }
}
