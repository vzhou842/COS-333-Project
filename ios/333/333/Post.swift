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
    
    static let dateFormatter = { () -> DateFormatter in
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return df
    }()
    
    static let niceDateFormatter = { () -> DateFormatter in
        let df = DateFormatter()
        df.dateFormat = "MM-dd hh:mm"
        return df
    }()
    
    let id: String
    let text: String?
    let imageUrl: String?
    let numComments: Int
    let numUpvotes: Int
    let date: Date
    let dateString: String
    
    // Initializes the Post object from a JSON server response.
    init(_ json: Dictionary<String, Any>) {
        id = json["post_id"] as! String
        text = json["text"] as? String
        imageUrl = json["image_url"] as? String
        numComments = json["num_comments"] as! Int
        numUpvotes = json["num_upvotes"] as! Int
        date = Post.dateFormatter.date(from: (json["timestamp"] as! String))!
        dateString = Post.niceDateFormatter.string(from: date)
    }
}
