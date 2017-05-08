//
//  Post.swift
//  333
//
//  Created by Victor Zhou on 4/22/17.
//  Copyright © 2017 333. All rights reserved.
//

import Foundation

// Posts are immutable objects.
class Post: NSObject {
    let user_id: String
    let id: String
    let text: String?
    let imageUrl: String?
    let numComments: Int
    var numUpvotes: Int
    let date: Date
    let dateString: String
    let loc: Dictionary<String, Any>
    
    // Initializes the Post object from a JSON server response.
    init(_ json: Dictionary<String, Any>) {
        user_id = json["user_id"] as! String
        id = json["post_id"] as! String
        text = json["text"] as? String
        imageUrl = json["image_url"] as? String
        numComments = json["num_comments"] as! Int
        numUpvotes = json["num_upvotes"] as! Int
        date = Utils.dateFormatter.date(from: (json["timestamp"] as! String))!
        dateString = Utils.niceDateFormatter.string(from: date)
        loc = json["loc"] as! Dictionary<String, Any>
    }
}
