import UIKit
import Foundation

// a custom class like the one that you want to archive needs to conform to NSCoding, so it can encode and decode (similar to serialization) itself and its properties when it's asked for by the archiver (NSKeydedArchiver or NSUserDefaults)
// because of that, the class also needs to subclass NSObject

// tutorial stackoverflow.com/questions/24659609/how-to-archive-and-unarchive-custom-objects-in-swift-or-how-to-save-custom-obje

class ImageData: NSObject, NSCoding {
    
    var name: String = ""
    
    
    // designated initializer
    init(name: String ) {
        // print("designated initializer")
        self.name = name
        
        
        
        super.init()
    }
    
    // MARK: - Conform to NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        //print("encodeWithCoder")
        aCoder.encodeObject(name, forKey: "Imagename")
        
    }
    
    // since we inherit from NSObject, we're not a final class -> therefore this initializer must be declared as 'required'
    // it also must be declared as a 'convenience' initializer, because we still have a designated initializer as well
    required convenience init?(coder aDecoder: NSCoder) {
        // print("decodeWithCoder")
        guard let unarchivedName = aDecoder.decodeObjectForKey("Imagename") as? String
            else {
                return nil
        }
        // now (we must) call the designated initializer
        self.init(name: unarchivedName)
    }
    
    // MARK: - Archiving & Unarchiving using NSUserDefaults
    
    class func saveImagesToUserDefaults(images: [ImageData]) {
        // first we need to convert our array of custom Player objects to a NSData blob, as NSUserDefaults cannot handle arrays of custom objects. It is limited to NSString, NSNumber, NSDate, NSArray, NSData. There are also some convenience methods like setBool, setInteger, ... but of course no convenience method for a custom object
        // note that NSKeyedArchiver will iterate over the 'players' array. So 'encodeWithCoder' will be called for each object in the array (see the print statements)
        let dataBlob = NSKeyedArchiver.archivedDataWithRootObject(images)
        
        // now we store the NSData blob in the user defaults
        NSUserDefaults.standardUserDefaults().setObject(dataBlob, forKey: "ImageInUserDefaults")
        
        // make sure we save/sync before loading again
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func loadImagesFromUserDefaults() -> [ImageData]? {
        // now do everything in reverse :
        //
        // - first get the NSData blob back from the user defaults.
        // - then try to convert it to an NSData blob (this is the 'as? NSData' part in the first guard statement)
        // - then use the NSKeydedUnarchiver to decode each custom object in the NSData array. This again will generate a call to 'init?(coder aDecoder)' for each element in the array
        // - and when that succeeded try to convert this [NSData] array to an [Player]
        guard let decodedNSDataBlob = NSUserDefaults.standardUserDefaults().objectForKey("ImageInUserDefaults") as? NSData,
            let loadedImagesFromUserDefault = NSKeyedUnarchiver.unarchiveObjectWithData(decodedNSDataBlob) as? [ImageData]
            else {
                return nil
        }
        
        return loadedImagesFromUserDefault
    }
    
  }