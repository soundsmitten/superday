import CoreData
import UIKit

///Implementation that uses CoreData to persist information on disk.
class CoreDataPersistencyService<T : BaseModel> : BasePersistencyService<T>
{
    //MARK: Fields
    let loggingService : LoggingService
    
    //MARK: Initializers
    init(loggingService: LoggingService)
    {
        self.loggingService = loggingService
    }
    
    //MARK: PersistencyService implementation
    override func getLast() -> T?
    {
        guard let managedElement = self.getLastManagedElement() else { return nil }
        
        let element = self.mapManagedObjectIntoElement(managedElement)
        return element
    }
    
    override func get(predicate: Predicate) -> [ T ]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: getEntityName())
        let nsPredicate = predicate.convertToNSPredicate()
        
        fetchRequest.predicate = nsPredicate
        
        do
        {
            let results = try self.getManagedObjectContext().fetch(fetchRequest) as! [NSManagedObject]
            
            let elements = results.map(self.mapManagedObjectIntoElement)
            loggingService.log(withLogLevel: .info, message: "\(elements.count) TimeSlots found")
            return elements
        }
        catch
        {
            //Returns an empty array if anything goes wrong
            loggingService.log(withLogLevel: .warning, message: "No TimeSlots found, return empty array")
            return []
        }
    }
    
    @discardableResult override func create(_ element: T) -> Bool
    {
        //Gets the managed object from CoreData's context
        let managedContext = self.getManagedObjectContext()
        let entity =  NSEntityDescription.entity(forEntityName: getEntityName(), in: managedContext)!
        let managedElement = NSManagedObject(entity: entity, insertInto: managedContext)
        
        //Sets the properties
        self.setManagedProperties(managedElement, element)
        
        do
        {
            try managedContext.save()
            return true
        }
        catch
        {
            return false
        }
    }
    
    override func update(_ predicate: Predicate, updateFunction: (AnyObject) -> ()) -> Bool
    {
        let managedContext = getManagedObjectContext()
        let entity = NSEntityDescription.entity(forEntityName: self.getEntityName(), in: managedContext)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        let predicate = predicate.convertToNSPredicate()
        
        request.entity = entity
        request.predicate = predicate
        
        do
        {
            guard let managedTimeSlot = try managedContext.fetch(request).first as AnyObject? else { return false }
            updateFunction(managedTimeSlot)
            
            try managedContext.save()
            
            return true
        }
        catch
        {
            self.loggingService.log(withLogLevel: .warning, message: "No \(T.self) found when trying to update")
            
            return false
        }
    }
    
    //MARK: Methods
    private func getManagedObjectContext() -> NSManagedObjectContext
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    
    private func setManagedProperties(_ managedElement: NSManagedObject, _ element: T)
    {
        let mirror = Mirror(reflecting: element)
        for child in mirror.children
        {
            guard let key = child.label else { continue }
            
            var value: Any?
            let mirrored = Mirror(reflecting: child.value)
            
            if mirrored.displayStyle != .optional
            {
                value = child.value
            }
            else if let firstChild = mirrored.children.first
            {
                value = firstChild.value
            }
            
            guard let actualValue = value else { continue }
            
            managedElement.setValue(mirrored.displayStyle == .enum ? String(describing: actualValue) : actualValue, forKey: key)
        }
    }
    
    private func mapManagedObjectIntoElement(_ managedObject: NSManagedObject) -> T
    {
        let result = T()
        result.setFromManagedObject(managedObject: managedObject)
        
        return result
    }
    
    private func getLastManagedElement() -> NSManagedObject?
    {
        let managedContext = self.getManagedObjectContext()
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = NSEntityDescription.entity(forEntityName: self.getEntityName(), in: managedContext)!
        request.fetchLimit = 5
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        
        do
        {
            guard let managedTimeSlot = try managedContext.fetch(request).first else { return nil }
            return managedTimeSlot as? NSManagedObject
        }
        catch
        {
            self.loggingService.log(withLogLevel: .error, message: "No TimeSlots found")
            return nil
        }
    }
    
    private func getEntityName() -> String
    {
        let fullName = String(describing: T.self)
        let range = fullName.range(of: ".", options: .backwards)
        if let range = range
        {
            return fullName.substring(from: range.upperBound)
        }
        else
        {
            return fullName
        }
    }
}
