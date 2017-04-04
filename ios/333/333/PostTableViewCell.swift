//
//  PostTableViewCell.swift
//  333
//
//  Created by Jose Rodriguez on 4/2/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postCaptionTextView: UITextView!
    @IBOutlet weak var timeStampTextView: UITextView!
    @IBOutlet weak var replyCountTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
