import Foundation
import CoreData

class CoreDataModelConverter<T : BaseModel>
{
    func getModel(fromManagedObject managedObject: NSManagedObject) -> T
    {
        fatalError("Not implemented")
    }
    
    func setManagedElementProperties(fromModel model: T, managedObject: NSManagedObject)
    {
        fatalError("Not implemented")
    }
}

class TimeSlotModelConverter : CoreDataModelConverter<TimeSlot>
{
    override func getModel(fromManagedObject managedObject: NSManagedObject) -> TimeSlot
    {
        let timeSlot = TimeSlot()
        timeSlot.startTime = managedObject.value(forKey: "startTime") as! Date
        timeSlot.endTime = managedObject.value(forKey: "endTime") as? Date
        timeSlot.category = Category(rawValue: managedObject.value(forKey: "category") as! String)!
        
        return timeSlot
    }
    
    override func setManagedElementProperties(fromModel model: TimeSlot, managedObject: NSManagedObject)
    {
        managedObject.setValue(model.startTime, forKey: "startTime")
        managedObject.setValue(model.endTime, forKey: "endTime")
        managedObject.setValue(model.category.rawValue, forKey: "category")
    }
}
