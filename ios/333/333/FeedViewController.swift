//
//  FeedViewController.swift
//  333
//
//  Created by Jose Rodriguez on 4/2/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    //Outlets
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var hotButton: UIButton!
    @IBOutlet weak var recentButton: UIButton!
    
    //Variables
    var posts = [Dictionary<String, Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postsTableView.delegate = self
        postsTableView.dataSource = self
        
        self.loadDataFromNetwork(nil)
        
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
        self.loadDataFromNetwork(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDataFromNetwork(_ refreshControl: UIRefreshControl?) {
        //Populate posts variable with posts from backend
        Networking.get(completion: { (dictionary) in
            self.posts = dictionary
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
    
    @IBAction func sortHot(_ sender: Any) {
        hotButton.layer.backgroundColor = UIColor.white.cgColor
        hotButton.setImage(UIImage(named: "sortHot"), for: .normal)
        recentButton.layer.backgroundColor = UIColor.clear.cgColor
        recentButton.setImage(UIImage(named: "recent"), for: .normal)
    }
    
    @IBAction func sortRecent(_ sender: Any) {
        recentButton.layer.backgroundColor = UIColor.white.cgColor
        recentButton.setImage(UIImage(named: "sortRecent"), for: .normal)
        hotButton.layer.backgroundColor = UIColor.clear.cgColor
        hotButton.setImage(UIImage(named: "hot"), for: .normal)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postTableViewCell") as! PostTableViewCell
        let postIndex = indexPath.row
        
        cell.postCaptionLabel.text = posts[postIndex]["text"] as? String
        let numComments = posts[postIndex]["num_comments"] as! Int
        cell.repliesLabel.text = "\(numComments)"
        //let timeStamp = posts[postIndex]["timestamp"] as! String
        //cell.timestampLabel.text = Networking.dateFormatter.date(from: timeStamp)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "postDetails", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
