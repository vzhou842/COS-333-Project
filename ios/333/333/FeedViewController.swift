//
//  FeedViewController.swift
//  333
//
//  Created by Jose Rodriguez on 4/2/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit
import ReachabilitySwift

protocol PostDetailsViewControllerDelegate {
    func didReturn()
}

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ComposeViewControllerDelegate, PostTableViewCellDelegate, PostDetailsViewControllerDelegate {
    
    //Outlets
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var hotButton: UIButton!
    @IBOutlet weak var recentButton: UIButton!
    
    //Variables
    var posts = [Post]()
    var timeStampFormatted: Date?
    var sortedByHot: Bool = true
    var sortedByRecent: Bool = false

    //Helpers
    let r = Reachability()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Location.sharedInstance.requestAuth(success: {
            self.loadDataFromNetwork(nil)
        }, failure: {
            Toaster.makeToastBottom(self.postsTableView, "Location Services must be enabled to use this app.")
        })
        
        postsTableView.delegate = self
        postsTableView.dataSource = self
        postsTableView.rowHeight = UITableViewAutomaticDimension
        postsTableView.estimatedRowHeight = 300
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        postsTableView.insertSubview(refreshControl, at: 0)
        
        recentButton.layer.cornerRadius = 8
        recentButton.layer.masksToBounds = true
        
        hotButton.layer.cornerRadius = 8
        hotButton.layer.masksToBounds = true
        hotButton.layer.backgroundColor = UIColor.white.cgColor
        hotButton.setImage(UIImage(named: "sortHot"), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postsTableView.reloadData()
    }
    
    func loadDataFromNetwork(_ refreshControl: UIRefreshControl?) {
        // Check if there's no internet connection.
        if r.currentReachabilityStatus == .notReachable {
            Toaster.makeToastBottom(self.view, "No Internet Connection.")
            if let r = refreshControl {
                r.endRefreshing()
            }
            return
        }

        let completion = {(posts: [Post]) in
            self.posts = posts
            self.postsTableView.reloadData()
            if let refreshControl = refreshControl {
                refreshControl.endRefreshing()
            }
        }

        //Populate posts variable with posts from backend
        if (self.sortedByHot)
        {
            Networking.getHotPosts(lat: Location.sharedInstance.lat, long: Location.sharedInstance.long, completion: completion)
        }
        else if (self.sortedByRecent)
        {
            Networking.getNewPosts(lat: Location.sharedInstance.lat, long: Location.sharedInstance.long, completion: completion)
        }
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        self.loadDataFromNetwork(refreshControl)
    }
    
    @IBAction func sortHot(_ sender: Any) {
        hotButton.layer.backgroundColor = UIColor.white.cgColor
        hotButton.setImage(UIImage(named: "sortHot"), for: .normal)
        recentButton.layer.backgroundColor = UIColor.clear.cgColor
        recentButton.setImage(UIImage(named: "recent"), for: .normal)
        
        sortedByHot = true
        sortedByRecent = false
        //sort posts by hot
        Networking.getHotPosts(lat: Location.sharedInstance.lat, long: Location.sharedInstance.long, completion: { (posts) in
            self.posts = posts
            self.postsTableView.reloadData()
        })
    }
    
    @IBAction func sortRecent(_ sender: Any) {
        recentButton.layer.backgroundColor = UIColor.white.cgColor
        recentButton.setImage(UIImage(named: "sortRecent"), for: .normal)
        hotButton.layer.backgroundColor = UIColor.clear.cgColor
        hotButton.setImage(UIImage(named: "hot"), for: .normal)
        
        sortedByHot = false
        sortedByRecent = true
        //sort posts by recency
        Networking.getNewPosts(lat: Location.sharedInstance.lat, long: Location.sharedInstance.long, completion: { (posts) in
            self.posts = posts
            self.postsTableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postTableViewCell") as! PostTableViewCell
        let postIndex = indexPath.row
        
        // Configure this cell for its post.
        cell.configureWithPost(posts[postIndex])
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "postDetails", sender: tableView.cellForRow(at: indexPath))
    }
    
    // MARK: - PostTableViewCellDelegate
    
    func didTapImageFromCell(_ cell: PostTableViewCell) {
        self.performSegue(withIdentifier: "showFullImage", sender: cell)
    }
    
    // MARK: - ComposeViewControllerDelegate
    
    func didComposePost(_ success: Bool) {
        Toaster.makeToastBottom(self.view, success ? "Post created!" : "Failed to create post. Please try again.")
        loadDataFromNetwork(nil)
    }

    func didReturn() {
        loadDataFromNetwork(nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "postDetails") {
            let vc = segue.destination as! PostDetailsViewController
            let cell = sender as! PostTableViewCell
            vc.post = cell.post
            vc.delegate = self
        } else if (segue.identifier == "compose") {
            let vc = segue.destination as! ComposeViewController
            vc.delegate = self
        } else if (segue.identifier == "showFullImage") {
            let vc = segue.destination as! ImageViewController
            vc.image = (sender as! PostTableViewCell).postImageView.image
        }
    }
}
