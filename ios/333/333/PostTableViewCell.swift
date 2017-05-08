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
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    
    //Variables
    var post: Post?
    var didVote: Bool = false
    var lat: Float!
    var long: Float!
    var city: String?
    
    var didUpvote: Bool = false
    var didDownvote: Bool = false
    
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
        let defaults = UserDefaults.standard
        didUpvote = defaults.bool(forKey: "up"+post.id)
        didDownvote = defaults.bool(forKey: "down"+post.id)
        
        if (didUpvote) {
            self.upButton.setImage(UIImage(named: "upvoteFilled"), for: .normal)
        }
        else {
            self.upButton.setImage(UIImage(named: "upvote"), for: .normal)
        }
        if (didDownvote) {
            self.downButton.setImage(UIImage(named: "downvoteFilled"), for: .normal)
        }
        else {
            self.downButton.setImage(UIImage(named: "downvote"), for: .normal)
        }
        
        postCaptionLabel.text = post.text
        repliesLabel.text = "\(post.numComments) Replies"
        if (post.numComments == 1)
        {repliesLabel.text = "\(post.numComments) Reply"}
        numVotesLabel.text = "\(post.numUpvotes)"
        let timeInterval = post.date.timeIntervalSinceNow
        timestampLabel.text = Utils.formatDate(-timeInterval)
        Utils.getCity(lat: Location.sharedInstance.lat, long: Location.sharedInstance.long, completion: { (city) in
            self.cityLabel.text = city
            self.city = city
        })
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
        
        Networking.createVote(lat: lat, long: long, user_id: user_id, object_id: object_id, up: up, completion: {() in
            if (self.didUpvote){
                self.numVotesLabel.text = "\(Int(self.numVotesLabel.text!)!-1)"
                self.didUpvote = false
                self.upButton.setImage(UIImage(named: "upvote"), for: .normal)
                self.post?.numUpvotes -= 1
            } else if (self.didDownvote) {
                self.numVotesLabel.text = "\(Int(self.numVotesLabel.text!)!+2)"
                self.didUpvote = true
                self.didDownvote = false
                self.downButton.setImage(UIImage(named: "downvote"), for: .normal)
                self.upButton.setImage(UIImage(named: "upvoteFilled"), for: .normal)
                self.post?.numUpvotes += 2
            } else {
                self.numVotesLabel.text = "\(Int(self.numVotesLabel.text!)!+1)"
                self.didUpvote = true
                self.upButton.setImage(UIImage(named: "upvoteFilled"), for: .normal)
                self.post?.numUpvotes += 1
            }
            
            print(self.didDownvote)
            print(self.didUpvote)
            let defaults = UserDefaults.standard
            defaults.set(self.didUpvote, forKey: "up"+(self.post?.id)!)
            defaults.set(self.didDownvote, forKey: "down"+(self.post?.id)!)
            defaults.synchronize()
            
            print(self.post?.numUpvotes)
        })
    }

    @IBAction func downvote(_ sender: Any) {
        let user_id = UIDevice.current.identifierForVendor!.uuidString
        let object_id = post!.id
        let up = false
        
        Networking.createVote(lat: lat, long: long, user_id: user_id, object_id: object_id, up: up, completion: {() in
            if (self.didUpvote){
                self.numVotesLabel.text = "\(Int(self.numVotesLabel.text!)!-2)"
                self.didUpvote = false
                self.didDownvote = true
                self.upButton.setImage(UIImage(named: "upvote"), for: .normal)
                self.downButton.setImage(UIImage(named: "downvoteFilled"), for: .normal)
                self.post?.numUpvotes -= 2
            } else if (self.didDownvote) {
                self.numVotesLabel.text = "\(Int(self.numVotesLabel.text!)!+1)"
                self.didDownvote = false
                self.downButton.setImage(UIImage(named: "downvote"), for: .normal)
                self.post?.numUpvotes += 1
            } else {
                self.numVotesLabel.text = "\(Int(self.numVotesLabel.text!)!-1)"
                self.didDownvote = true
                self.downButton.setImage(UIImage(named: "downvoteFilled"), for: .normal)
                self.post?.numUpvotes -= 1
            }
            
            print(self.didDownvote)
            print(self.didUpvote)
            let defaults = UserDefaults.standard
            defaults.set(self.didUpvote, forKey: "up"+(self.post?.id)!)
            defaults.set(self.didDownvote, forKey: "down"+(self.post?.id)!)
            defaults.synchronize()
            
            print(self.post?.numUpvotes)
        })
    }
}
