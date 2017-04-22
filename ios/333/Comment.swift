//
//  Comment.swift
//  333
//
//  Created by Victor Zhou on 4/22/17.
//  Copyright © 2017 333. All rights reserved.
//

import Foundation

// Comments are immutable objects.
class Comment: NSObject {
    let comment_id: String
    let post_id: String
    let text: String
    let user_id: String
    let date: Date
    let numUpvotes: Int
    
    // Initializes the Comment object from a JSON server response.
    init(_ json: Dictionary<String, Any>) {
        comment_id = json["comment_id"] as! String
        post_id = json["post_id"] as! String
        text = json["text"] as! String
        user_id = json["user_id"] as! String
        date = Utils.dateFormatter.date(from: (json["timestamp"] as! String))!
        numUpvotes = json["num_upvotes"] as! Int
    }
}
