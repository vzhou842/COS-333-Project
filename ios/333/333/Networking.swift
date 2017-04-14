//
//  Networking.swift
//  333
//
//  Created by Sarah Zhou on 4/8/17.
//  Copyright © 2017 333. All rights reserved.
//

import Alamofire

class Networking {
    
    static let baseurl = "https://hallowed-moment-163600.appspot.com"
    static let dateFormatter = DateFormatter()
    static let niceDateFormatter1: DateFormatter? = DateFormatter()
    static let niceDateFormatter2: DateFormatter? = DateFormatter()

    //Create a new post with the specified parameters.
    static func createPost(text:String?, image_url:String?, user_id:String, lat:Float, long:Float) {
        
        let parameters: Parameters = [
            "text": text ?? "",
            "image_url": image_url ?? "",
            "user_id": user_id,
            "lat": lat,
            "long": long
        ]
        
        Alamofire.request("\(baseurl)/api/posts", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { response in
            
            if let json = response.result.value {
                print("JSON: \(json)")
            }
        })
    }
    
    //Get all new posts and run the completion handler if successful.
    static func getPosts(completion: @escaping ([Dictionary<String, Any>]) -> Void) {
        
        Alamofire.request("\(baseurl)/api/posts/new?lat=0.25&long=0").responseJSON { response in
            
            if let JSON = response.result.value {
                completion(JSON as! [Dictionary<String, Any>])
            }
            
            else {
                print("ERROR")
            }
        }
    }
    
    //Create a new vote with the specified parameters.
    static func createVote(user_id:String, object_id:String, up:Bool) {
        let parameters: Parameters = [
            "user_id": user_id,
            "object_id": object_id,
            "up": up
        ]
        
        Alamofire.request("\(baseurl)/api/votes", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { response in
            
            if let json = response.result.value {
                print("JSON: \(json)")
            }
        })
    }
    
    //Create a new comment with the specified parameters.
    static func createComment(text:String, user_id:String, post_id:String) {
        let parameters: Parameters = [
            "text": text,
            "user_id": user_id,
            "post_id": post_id,
        ]
        
        Alamofire.request("\(baseurl)/api/comments", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { response in
            
            if let json = response.result.value {
                print("JSON: \(json)")
            }
        })
    }
    
    //Get all comments and run the completion handler if successful.
    static func getComments(post_id:String, completion: @escaping ([Dictionary<String, Any>]) -> Void) {
        
        Alamofire.request("\(baseurl)/api/comments/new?post_id="+post_id).responseJSON { response in
            
            if let JSON = response.result.value {
                completion(JSON as! [Dictionary<String, Any>])
            }
                
            else {
                print("ERROR")
            }
        }
    }
    
    static func initializeDateFormatter() {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        niceDateFormatter1!.dateFormat = "hh:mm"
        niceDateFormatter2!.dateFormat = "EEEE"
    }
}


