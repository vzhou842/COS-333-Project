//
//  ComposeViewController.swift
//  333
//
//  Created by Sarah Zhou on 4/3/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    let imagePicker = UIImagePickerController()
    
    @IBAction func cameraRoll(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func camera(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func sendPost(_ sender: Any) {
        Networking.post(text: postTextView.text, image_url: nil, user_id: "hallo", lat: 10, long: -6)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        postTextView.delegate = self
        postTextView.text = "What's on your mind?"
        postTextView.textColor = UIColor.lightGray
        
        countLabel.text = "200"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        countLabel.text = "\(200 - textView.text.characters.count)"
        if 200 - textView.text.characters.count < 0 {
            countLabel.textColor = UIColor.red
        } else {
            countLabel.textColor = UIColor.darkGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "What's on your mind?"
            textView.textColor = UIColor.lightGray
        }
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
