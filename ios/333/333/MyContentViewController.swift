//
//  MyContentViewController.swift
//  333
//
//  Created by Jose Rodriguez on 4/24/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit

class MyContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    //Outlets
    @IBOutlet weak var postsTableView: UITableView!
    
    //Variables
    var posts = [Post]()
    var timeStampFormatted: Date?
    var filteredByReplies: Bool?
    var filteredByUser: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postsTableView.delegate = self
        postsTableView.dataSource = self
        postsTableView.rowHeight = UITableViewAutomaticDimension
        postsTableView.estimatedRowHeight = 300

        self.loadDataFromNetwork(nil)
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        postsTableView.insertSubview(refreshControl, at: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadDataFromNetwork(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDataFromNetwork(_ refreshControl: UIRefreshControl?) {
        //Populate posts variable with posts from backend
        Networking.getNewPosts(completion: { (posts) in
            self.posts = posts
            
            if self.filteredByReplies != nil && self.filteredByReplies! == true {
                //filter by things you've replied to
                self.posts = self.posts.filter({ (post) -> Bool in
                    post.user_id == UIDevice.current.identifierForVendor!.uuidString
                })
            }
                
            else if self.filteredByUser != nil && self.filteredByUser! == true {
                //filter by things you've posted
                self.posts = self.posts.filter({ (post) -> Bool in
                    post.user_id == UIDevice.current.identifierForVendor!.uuidString
                })
            }
            
            self.postsTableView.reloadData()
            if let refreshControl = refreshControl {
                refreshControl.endRefreshing()
            }
        })
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        self.loadDataFromNetwork(refreshControl)
        
        // Tell the refreshControl to stop spinning
        refreshControl.endRefreshing()
    }
    
    func formatDate(_ number: TimeInterval) -> String {
        var formatted = ""
        
        if number < 60 {
            formatted = String(format: "%.0f", Double(number)) + "s"
        } else if number < 3600 {
            formatted = String(format: "%.0f", Double(number) / 60.0) + "m"
        } else if number < 86400 {
            formatted = String(format: "%.0f", Double(number) / 3600.0) + "h"
        } else if number < 2073600 {
            formatted = String(format: "%.0f", Double(number) / 86400.0) + "d"
        }
        
        return formatted
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postTableViewCell") as! PostTableViewCell
        let postIndex = indexPath.row
        
        // Configure this cell for its post.
        cell.configureWithPost(posts[postIndex])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "postDetails", sender: tableView.cellForRow(at: indexPath))
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "postDetails") {
            let vc = segue.destination as! PostDetailsViewController
            vc.post = (sender as! PostTableViewCell).post
        }
    }
 

}
