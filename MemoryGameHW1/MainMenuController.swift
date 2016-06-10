//
//  MainMenuController.swift
//  MemoryGameHW2
//
//  Created by Seiran on 21.05.16.
//  Copyright © 2016 SVTeam. All rights reserved.
//



import UIKit

class MainMenuController: UIViewController {
    
    
    @IBOutlet weak var nameLable: UITextField! 
    
    let preferences = NSUserDefaults.standardUserDefaults()
    
    let currentUserKey = "currentUser"
    
    
    @IBAction func newGamePressed(sender: AnyObject) {
        print("Name \(nameLable.text)")
        
        //insert the name into shared preferences
       
        preferences.setObject(nameLable.text, forKey: currentUserKey)
        
        //  Save to disk
        preferences.synchronize()
        
                
    
    
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        if preferences.objectForKey(currentUserKey) == nil {
            //  Doesn't exist
            nameLable.text="Insert Name Here"
        } else {
            
            nameLable.text=preferences.stringForKey(currentUserKey)
        }
        
        let im0 = ImageData(name: "cell0")
        let im1 = ImageData(name: "cell1")
        let im2 = ImageData(name: "cell2")
        let im3 = ImageData(name: "cell3")
        let im4 = ImageData(name: "cell4")
        let im5 = ImageData(name: "cell5")
        let im6 = ImageData(name: "cell6")
        let im7 = ImageData(name: "cell7")
        let im8 = ImageData(name: "cell8")
        
        let imArray = [im0,im1,im2,im3,im4,im5,im6,im7,im8]
        ImageData.saveImagesToUserDefaults(imArray)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
       /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
