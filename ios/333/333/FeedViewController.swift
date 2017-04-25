//
//  FeedViewController.swift
//  333
//
//  Created by Jose Rodriguez on 4/2/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit
import CoreLocation

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, CLLocationManagerDelegate {
    
    //Outlets
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var hotButton: UIButton!
    @IBOutlet weak var recentButton: UIButton!
    
    //Variables
    var posts = [Post]()
    var timeStampFormatted: Date?
    var sortedByHot: Bool = true
    var sortedByRecent: Bool = false
    
    //Location
    let locationManager = CLLocationManager()
    var lat: CLLocationDegrees! = 0
    var long: CLLocationDegrees! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            lat = locationManager.location!.coordinate.latitude
            long = locationManager.location!.coordinate.longitude
        }
        
        postsTableView.delegate = self
        postsTableView.dataSource = self
        postsTableView.rowHeight = UITableViewAutomaticDimension
        postsTableView.estimatedRowHeight = 300
        
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
            if (self.sortedByHot)
            {
                Networking.getHotPosts(completion: { (posts) in
                self.posts = posts
                self.postsTableView.reloadData()
            })}
            else if (self.sortedByRecent)
            {
                Networking.getNewPosts(completion: { (posts) in
                self.posts = posts
                self.postsTableView.reloadData()
            })}
    
            if let refreshControl = refreshControl {
                refreshControl.endRefreshing()
            }
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
        
        sortedByHot = true
        sortedByRecent = false
        //sort posts by hot
        Networking.getHotPosts(completion: { (posts) in
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
        Networking.getNewPosts(completion: { (posts) in
            self.posts = posts
            self.postsTableView.reloadData()
        })
    }
    
    @IBAction func onTouchHome(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"profileViewController") as! ProfileViewController
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        present(viewController, animated: false, completion: nil)
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
