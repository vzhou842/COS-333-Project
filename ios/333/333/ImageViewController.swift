//
//  ImageViewController.swift
//  333
//
//  Created by Sarah Zhou on 5/8/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    var image: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
