import UIKit
import Foundation

// a custom class like the one that you want to archive needs to conform to NSCoding, so it can encode and decode (similar to serialization) itself and its properties when it's asked for by the archiver (NSKeydedArchiver or NSUserDefaults)
// because of that, the class also needs to subclass NSObject

// tutorial stackoverflow.com/questions/24659609/how-to-archive-and-unarchive-custom-objects-in-swift-or-how-to-save-custom-obje

class GamePlayer: NSObject, NSCoding {
    
    var name: String = ""
    var score : Int = 0
    
    // designated initializer
    init(name: String, score:Int ) {
       // print("designated initializer")
        self.name = name
        self.score = score
        
        
        super.init()
    }
    
    // MARK: - Conform to NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        //print("encodeWithCoder")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(score, forKey: "score")
    }
    
    // since we inherit from NSObject, we're not a final class -> therefore this initializer must be declared as 'required'
    // it also must be declared as a 'convenience' initializer, because we still have a designated initializer as well
    required convenience init?(coder aDecoder: NSCoder) {
       // print("decodeWithCoder")
        guard let unarchivedName = aDecoder.decodeObjectForKey("name") as? String
            else {
                return nil
        }
        guard let unarchivedScore = aDecoder.decodeObjectForKey("score") as? Int
            else {
                return nil
        }
        
        // now (we must) call the designated initializer
        self.init(name: unarchivedName,score: unarchivedScore)
    }
    
    // MARK: - Archiving & Unarchiving using NSUserDefaults
    
    class func savePlayersToUserDefaults(players: [GamePlayer]) {
        // first we need to convert our array of custom Player objects to a NSData blob, as NSUserDefaults cannot handle arrays of custom objects. It is limited to NSString, NSNumber, NSDate, NSArray, NSData. There are also some convenience methods like setBool, setInteger, ... but of course no convenience method for a custom object
        // note that NSKeyedArchiver will iterate over the 'players' array. So 'encodeWithCoder' will be called for each object in the array (see the print statements)
        let dataBlob = NSKeyedArchiver.archivedDataWithRootObject(players)
        
        // now we store the NSData blob in the user defaults
        NSUserDefaults.standardUserDefaults().setObject(dataBlob, forKey: "PlayersInUserDefaults")
        
        // make sure we save/sync before loading again
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func loadPlayersFromUserDefaults() -> [GamePlayer]? {
        // now do everything in reverse :
        //
        // - first get the NSData blob back from the user defaults.
        // - then try to convert it to an NSData blob (this is the 'as? NSData' part in the first guard statement)
        // - then use the NSKeydedUnarchiver to decode each custom object in the NSData array. This again will generate a call to 'init?(coder aDecoder)' for each element in the array
        // - and when that succeeded try to convert this [NSData] array to an [Player]
        guard let decodedNSDataBlob = NSUserDefaults.standardUserDefaults().objectForKey("PlayersInUserDefaults") as? NSData,
            let loadedPlayersFromUserDefault = NSKeyedUnarchiver.unarchiveObjectWithData(decodedNSDataBlob) as? [GamePlayer]
            else {
                return nil
        }
        
        return loadedPlayersFromUserDefault
    }
    
    // MARK: - Archivig & Unarchiving using a regular file (using NSKeyedUnarchiver)
    
    private class func getFileURL() -> NSURL {
        // construct a URL for a file named 'Players' in the DocumentDirectory
        let documentsDirectory = NSFileManager().URLsForDirectory((.DocumentDirectory), inDomains: .UserDomainMask).first!
        let archiveURL = documentsDirectory.URLByAppendingPathComponent("Players")
        
        return archiveURL
    }
    
    class func savePlayersToDisk(players: [GamePlayer]) {
        let success = NSKeyedArchiver.archiveRootObject(players, toFile: GamePlayer.getFileURL().path!)
        if !success {
            print("failed to save") // you could return the error here to the caller
        }
    }
    
    class func loadPlayersFromDisk() -> [GamePlayer]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(GamePlayer.getFileURL().path!) as? [GamePlayer]
    }
}