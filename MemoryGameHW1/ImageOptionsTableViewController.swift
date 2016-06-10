//
//  ImageOptionsTableViewController.swift
//  MemoryGameHW1
//
//  Created by Admin on 10/06/2016.
//  Copyright © 2016 SVTeam. All rights reserved.
//

import UIKit


class ImageOptionsTableViewController: UITableViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var retreivedImages = ImageData.loadImagesFromUserDefaults()
    var chosenIndexPath: NSIndexPath!
    var downloadedImage: UIImage!
    var urlForImage = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
               return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 8
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ImageOptionsTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ImageOptionsTableViewCell

        // Configure the cell...
        
        
       // cell.imageV.image =  UIImage(named: "default-user")!
        let im = UIImage(named: retreivedImages![indexPath.row].name)!
        
        cell.imageV1.image = im
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        chosenIndexPath = indexPath

        
        // create the alert
        let alert = UIAlertController(title: "Notice", message: "Chose source of picture", preferredStyle: UIAlertControllerStyle.Alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default, handler: {action in self.handlerForImagePicker(indexPath)}))
        alert.addAction(UIAlertAction(title: "URL", style: UIAlertActionStyle.Default, handler: {action in self.handlerForUrlDownload(indexPath)}))
        alert.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {action in self.handlerForCamera(indexPath)}))
        alert.addAction(UIAlertAction(title: "Cancell", style: UIAlertActionStyle.Cancel, handler: nil))
        
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
    
    }
    
    func handlerForImagePicker(indexPath :NSIndexPath){
        print("ImagePicker")
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func handlerForUrlDownload(indexPath :NSIndexPath){
         print("URL")
        
        let alert = UIAlertController(title: "Alert", message: "Enter the URL for image:", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "url"
            textField.secureTextEntry = false
        })
        
        alert.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.Default, handler: { action in
            if let text = alert.textFields!.first! as? UITextField{
                self.urlEnteredHandler(text.text!)
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func urlEnteredHandler(url: String){
        
        if let checkedUrl = NSURL(string: url) {
            downloadImage(checkedUrl)
        }
    }
    
    func handlerForCamera(indexPath :NSIndexPath){
         print("Camera")
        // the below section should work, but there is no camera in XCode emulator, and there is
        // some hardware exception
        
        /*chosenIndexPath = indexPath
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .Camera
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)*/
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // implementing picker delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var newImage: UIImage
        
        if let possibleImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        let imageName = NSUUID().UUIDString
        let imagePath = getDocumentsDirectory().stringByAppendingPathComponent(imageName)
        
        if let pngData = UIImagePNGRepresentation(newImage) {
            pngData.writeToFile(imagePath, atomically: true)
            
            // saving to preferences
            retreivedImages![chosenIndexPath.row].name = imagePath
            ImageData.saveImagesToUserDefaults(retreivedImages!)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        // refreshing tableview to show new picture
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    
    // get directory for saving pictures
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    func downloadImage(url: NSURL){
        print("Download Started")
        print("lastPathComponent: " + (url.lastPathComponent ?? ""))
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                print(response?.suggestedFilename ?? "")
                print("Download Finished")
                self.downloadedImage = UIImage(data: data)
                
                let imageName = NSUUID().UUIDString
                let imagePath = self.getDocumentsDirectory().stringByAppendingPathComponent(imageName)
                if let pngData = UIImagePNGRepresentation(self.downloadedImage) {
                    pngData.writeToFile(imagePath, atomically: true)
                    
                    // saving to preferences
                    self.retreivedImages![self.chosenIndexPath.row].name = imagePath
                    ImageData.saveImagesToUserDefaults(self.retreivedImages!)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
                
            }
        }
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }

    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
