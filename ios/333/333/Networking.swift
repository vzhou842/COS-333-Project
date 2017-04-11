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

    static func post(text:String?, image_url:String?, user_id:String, lat:Float, long:Float) {
        
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
    
    static func get(completion: @escaping ([Dictionary<String, Any>]) -> Void){
        
        Alamofire.request("\(baseurl)/api/posts/new?lat=0.25&long=0").responseJSON { response in
            
            if let JSON = response.result.value {
                completion(JSON as! [Dictionary<String, Any>])
            }
            
            else {
                print("ERROR")
            }
        }
    }
    
    class func initializeDateFormatter() {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        niceDateFormatter1!.dateFormat = "hh:mm"
        niceDateFormatter2!.dateFormat = "EEEE"
    }
}


