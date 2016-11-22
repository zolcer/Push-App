//
//  ViewController.swift
//  bakalarka
//
//  Created by Zolcer on 07/11/2016.
//  Copyright © 2016 Zolcer. All rights reserved.
//

import UIKit
import CoreMotion
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit


class ViewController: UIViewController {
    
    var meno:String!
    var x: Double! = 0.0
    var wasalert: Bool! = false
    var rep: Bool! = false
    var timer: Timer!
    var gyro: Bool! = false
    var acc: Bool! = false
    var daco: Double!
    var dacoy: Double!
    var dacoz: Double!
    var yaw: Double!
    var pitch: Double!
    var roll: Double!
    var accx: Double!=0.0
    var accy: Double!
    var accz: Double!
    var reps: Int!=0
    
    var lastX: Double = 0.0
    var lastY: Double = 0.0
    var lastZ: Double = 0.0
    var kUpdateFrequency: Double!
    var cutOffFrequency: Double = 0.0
    var dt: Double = 0.0
    var RC: Double = 0.0
    var alpha: Double = 0.0
    let kFilteringFactor = 0.05
    
    let manager = CMMotionManager()

    

    @IBOutlet weak var ZField: UILabel!
    @IBOutlet weak var YField: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var XField: UILabel!
    @IBOutlet weak var TextField: UILabel!
    @IBOutlet weak var Accelerometer: UIButton!
    @IBOutlet weak var Gyroscope: UIButton!
    @IBAction func Accelerometer(_ sender: UIButton) {
        TextField.text="Accelerometer chosen"
        acc=true
        gyro=false
    }
    @IBAction func startExercise(_ sender: Any) {
    }
    
    @IBAction func endExercise(_ sender: Any) {
        TextField.text="Choose some sensor"
    }
    
    
    
    
    
    @IBAction func Gyroscope(_ sender: UIButton) {
        if !manager.isGyroActive {TextField.text="NE idee"}
        TextField.text="Gyroscope chosen"
        acc = false
        gyro = true
        
    }
    
    func gyroutput(){
        if gyro==true{

            message.text="make some move to recognize the exercise"

            
        daco = manager.gyroData?.rotationRate.x
        dacoy = manager.gyroData?.rotationRate.y
        dacoz = manager.gyroData?.rotationRate.z
            
            yaw=manager.deviceMotion?.attitude.yaw
            pitch=manager.deviceMotion?.attitude.pitch
            roll=manager.deviceMotion?.attitude.roll
            
            
            if pitch>1.0 && wasalert==false{
                //message.text=" doing sit-ups"
                let alert = UIAlertController(title: "Recognized movement", message: "Are you doing sit-ups?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.cancel, handler: { action in
                    //run your function here
                    self.setExercise()
                }))
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            
            }
            if pitch<1.0 {message.text=""}
            if rep==true{StartRecommendedExercise()}


            
        XField.text=String(roll)
        YField.text=String(yaw)
        ZField.text=String(pitch)
        
        }
        if acc==true{
            daco=manager.accelerometerData?.acceleration.x
            dacoy=manager.accelerometerData?.acceleration.y
            dacoz=manager.accelerometerData?.acceleration.z
            
            
                //accx=manager.deviceMotion?.userAcceleration.x
                //accy=manager.deviceMotion?.userAcceleration.y
                //accz=manager.deviceMotion?.userAcceleration.z
            
           if accx==0.0{
                self.accx = ((manager.deviceMotion?.userAcceleration.x)! * kFilteringFactor)
                self.accy = ((manager.deviceMotion?.userAcceleration.y)! * kFilteringFactor)
                self.accz = ((manager.deviceMotion?.userAcceleration.z)! * kFilteringFactor)
            }
           else{
            
            self.accx = ((manager.deviceMotion?.userAcceleration.x)! * kFilteringFactor)+(self.accx*(1.0-kFilteringFactor))
            self.accy = ((manager.deviceMotion?.userAcceleration.y)! * kFilteringFactor)+(self.accy*(1.0-kFilteringFactor))
            self.accz = ((manager.deviceMotion?.userAcceleration.z)! * kFilteringFactor)+(self.accz*(1.0-kFilteringFactor))

            }
            
            // LOW PASS FILTER
            //accelX = (acceleration.x * kFilteringFactor) + (accelX * (1.0 - kFilteringFactor));
           //HIGH PASS = accx-lowpass
            //accelX = acceleration.x - ( (acceleration.x * kFilteringFactor) + (accelX * (1.0 - kFilteringFactor)) );

            /*
            else{
            
            self.accx = self.alpha * (self.accx + (manager.deviceMotion?.userAcceleration.x)! - self.lastX)
            self.accy = self.alpha * (self.accy + (manager.deviceMotion?.userAcceleration.y)! - self.lastY)
            self.accz = self.alpha * (self.accz + (manager.deviceMotion?.userAcceleration.z)! - self.lastZ)
            }
            */
            
            accx=(manager.deviceMotion?.userAcceleration.x)! - accx
            accy=(manager.deviceMotion?.userAcceleration.y)! - accy
            accz=(manager.deviceMotion?.userAcceleration.z)! - accz

            
            self.lastX = (manager.deviceMotion?.userAcceleration.x)!
            self.lastY = (manager.deviceMotion?.userAcceleration.y)!
            self.lastZ = (manager.deviceMotion?.userAcceleration.z)!

            if accy*10>1.0 {message.text="chodis rovno"}
            if accx*10>1.0 {message.text="chodis bokom"}
            
            XField.text=String(accx*10)
            YField.text=String(accy*10)
            ZField.text=String(accz*10)
        }
        
    }
    
    func setExercise(){
        wasalert=true
        rep=true
    }
    
    func StartRecommendedExercise(){
        TextField.text="doing Sit-ups"
        if pitch>1.0 {x = 1}
        if pitch<1.0 {x = x-1}
        message.text=String(reps)
        if x==0 {reps=reps+1}
    }
    
    @IBAction func onClickFacebookButton(sender: UIButton){
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "MenuController") as! MenuController
                        self.present(vc, animated: true, completion: nil)
                        fbLoginManager.logOut()

                    }
                }
            }
            
        }
    }
    
    var dict : [String : AnyObject]!

    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    print(result!)
                    self.meno=self.dict["first_name"] as? String
                    print(self.meno)
                    print(self.dict)
                }
            })
            
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        /*
        lastX = 0.0
        lastY = 0.0
        lastZ = 0.00
        kUpdateFrequency = 60.0
        cutOffFrequency = 5.0
        dt = 1.0 / kUpdateFrequency
        RC = 1.0 / cutOffFrequency
        alpha = RC / (dt+RC)
        */
        //manager.startAccelerometerUpdates()
        //manager.startGyroUpdates()
       // manager.startMagnetometerUpdates()
        //manager.startDeviceMotionUpdates()
        //timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.gyroutput), userInfo: nil, repeats: true)
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

