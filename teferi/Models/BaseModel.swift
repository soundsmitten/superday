import Foundation
import CoreData

class BaseModel : NSObject
{
    required override init()
    {
        
    }
    
    func setFromManagedObject(managedObject: NSManagedObject)
    {
        fatalError("Not implemented")
    }
}
