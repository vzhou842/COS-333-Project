//
//  PostTableViewCell.swift
//  333
//
//  Created by Jose Rodriguez on 4/2/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit
import SDWebImage
import ReachabilitySwift

protocol PostTableViewCellDelegate {
    func didTapImageFromCell(_ cell: PostTableViewCell)
    func removeCell(_ cell: PostTableViewCell)
    func showNoInternetNotif()
}

class PostTableViewCell: UITableViewCell {
    
    var delegate: PostTableViewCellDelegate?
    
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
    var post: Post!
    var didVote: Bool = false
    var didUpvote: Bool = false
    var didDownvote: Bool = false
    var isVoting: Bool = false
    let r = Reachability()!

    override func awakeFromNib() {
        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
    }

    func configureWithPost(_ post: Post) {
        self.post = post

        let defaults = UserDefaults.standard
        setVotes(up: defaults.bool(forKey: "up" + post.id), down: defaults.bool(forKey: "down" + post.id))

        postCaptionLabel.text = post.text
        setNumUpvotes(post.numUpvotes)
        repliesLabel.text = "\(post.numComments) Comments"
        if (post.numComments == 1) {
            repliesLabel.text = "\(post.numComments) Comment"
        }

        let timeInterval = post.date.timeIntervalSinceNow
        timestampLabel.text = "\(Utils.formatDate(-timeInterval))"
        
        cityLabel.text = post.city

        if let image_url = post.imageUrl {
            // We have an image. Let it take up at most half the screen's height.
            self.postImageViewHeightConstraint.constant = UIScreen.main.bounds.height / 2

            // Display the image.
            postImageView.sd_setImage(with: URL(string: image_url), completed: { (img: UIImage?, e: Error?, _: SDImageCacheType, _: URL?) in
                if (img == nil) {
                    print("Failed to set image" + e.debugDescription)
                }
            })
        } else {
            // No image.
            self.postImageViewHeightConstraint.constant = 0
        }
    }
    
    func setVotes(up: Bool, down: Bool) {
        self.didUpvote = up
        self.didDownvote = down

        if (up) {
            self.upButton.setImage(UIImage(named: "upvoteFilled"), for: .normal)
        } else {
            self.upButton.setImage(UIImage(named: "upvote"), for: .normal)
        }

        if (down) {
            self.downButton.setImage(UIImage(named: "downvoteFilled"), for: .normal)
        } else {
            self.downButton.setImage(UIImage(named: "downvote"), for: .normal)
        }
        
        let defaults = UserDefaults.standard
        defaults.set(up, forKey: "up" + self.post.id)
        defaults.set(down, forKey: "down" + self.post.id)
        defaults.synchronize()
    }

    func setNumUpvotes(_ num: Int) {
        self.post.numUpvotes = num
        self.numVotesLabel.text = "\(num)"
    }

    @IBAction func upvote(_ sender: Any) {
        vote(up: true)
    }

    @IBAction func downvote(_ sender: Any) {
        vote(up: false)
    }

    func vote(up: Bool) {
        // If we're currently already sending a vote to the server, ignore this new vote.
        if (isVoting) {
            return
        }

        // If there's no internet connection, show a toast.
        if r.currentReachabilityStatus == .notReachable {
            if let d = delegate {
                d.showNoInternetNotif()
            }
            return
        }
        
        isVoting = true
        let user_id = Account.sharedInstance.user_id
        let object_id = post.id
        
        Networking.createVote(lat: Location.sharedInstance.lat, long: Location.sharedInstance.long, user_id: user_id, object_id: object_id, up: up, completion: {(success) in
            self.isVoting = false

            if (!success) {
                return
            }

            if (self.didUpvote && up) {
                // Undo upvote.
                self.setNumUpvotes(self.post.numUpvotes - 1)
                self.setVotes(up: false, down: false)
            } else if (self.didUpvote && !up) {
                // Change up -> down.
                self.setNumUpvotes(self.post.numUpvotes - 2)
                self.setVotes(up: false, down: true)
            } else if (self.didDownvote && up) {
                // Change down -> up.
                self.setNumUpvotes(self.post.numUpvotes + 2)
                self.setVotes(up: true, down: false)
            } else if (self.didDownvote && !up) {
                // Undo downvote.
                self.setNumUpvotes(self.post.numUpvotes + 1)
                self.setVotes(up: false, down: false)
            } else {
                // Create vote.
                self.setNumUpvotes(self.post.numUpvotes + (up ? 1 : -1))
                self.setVotes(up: up, down: !up)
            }

            // Check if this post fell below the -5 vote threshold.
            // If so, notify the delegate.
            if (self.post.numUpvotes <= -5) {
                if let delegate = self.delegate {
                    delegate.removeCell(self)
                }
            }
        })
    }
    
    @IBAction func fullImage(_ sender: Any) {
        if let d = delegate {
            d.didTapImageFromCell(self)
        }
    }
}
