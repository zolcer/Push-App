//
//  MenuController.swift
//  bakalarka
//
//  Created by Zolcer on 14/11/2016.
//  Copyright © 2016 Zolcer. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class MenuController: UIViewController{
 
    var dict : [String : AnyObject]!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var imageProfile: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (FBSDKAccessToken.current() != nil) {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    self.Name.text=self.dict["first_name"] as? String
                    let userID = self.dict["id"] as! String
                    let facebookProfileUrl = NSURL(string: "https://graph.facebook.com/" + (userID as String) + "/picture?type=large")
                    //if let fbpicUrl = NSURL(string: facebookProfileUrl){
                    if let data = NSData(contentsOf: facebookProfileUrl! as URL) {
                        
                        self.imageProfile.image = UIImage(data: data as Data)
                        self.imageProfile.layer.borderWidth = 1
                        self.imageProfile.layer.masksToBounds = false
                        self.imageProfile.layer.borderColor = UIColor.red.cgColor
                        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.height/2
                        self.imageProfile.clipsToBounds = true
 
                    }
                //}
                }
                
            })
            
        
        
    }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
