//
//  FeedViewController.swift
//  333
//
//  Created by Jose Rodriguez on 4/2/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Outlets
    @IBOutlet weak var filterFeedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var postsTableView: UITableView!
    
    //Variables
    var posts = [Dictionary<String, Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        postsTableView.delegate = self
        postsTableView.dataSource = self
        
        filterFeedSegmentedControl.setTitle("New", forSegmentAt: 0)
        filterFeedSegmentedControl.setTitle("Supa Hot", forSegmentAt: 1)
        
        //Populate posts variable with posts from backend
        
        Networking.get(completion: { (dictionary) in
            self.posts = dictionary
            self.postsTableView.reloadData()
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func onClickHomeButton(_ sender: Any) {
    }

    @IBAction func onClickComposeButton(_ sender: Any) {
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
