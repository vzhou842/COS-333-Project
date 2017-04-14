//
//  PostDetailsViewController.swift
//  333
//
//  Created by Jose Rodriguez on 4/6/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit

class PostDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Outlets
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var replyTextField: UITextField!
    
    //Variables
    var post = Dictionary<String, Any>()
    var comments = [Dictionary<String, Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "replyTableViewCell") as! ReplyTableViewCell
        
        let comment = comments[indexPath.row]
        
        //Set cell properties
        cell.captionLabel.text = comment["text"] as! String?
        
        return cell
    }
    
    @IBAction func onTouchSend(_ sender: Any) {
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
