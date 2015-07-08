//
//  authController.swift
//  ParseStarterProject
//
//  Created by Alex Wu on 30/6/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import Parse

class authViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        println(PFUser.currentUser())
        
        if PFUser.currentUser()?.username != nil {
            
            self.performSegueWithIdentifier("loginSegue", sender: self)
            
        }
        
    }
    
    @IBAction func btnLogin(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground("t1111", password:"s123123") {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                // Do stuff after successful login.
                println("Login Success")
                self.performSegueWithIdentifier("loginSegue", sender: self)
            } else {
                // The login failed. Check error to see why.
                println("Login Fail")
            }
        }
    }
    
    @IBAction func btnSignUp(sender: AnyObject) {
        var user = PFUser()
        user.username = "t1111"
        user.password = "s123123"

        // other fields can be set just like with PFObject
        
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo?["error"] as? NSString
                // Show the errorString somewhere and let the user try again.
                println(errorString)
            } else {
                // Hooray! Let them use the app now.
                println("SignUp Success")
                
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "loginSegue" {
            
        }
    }
}
