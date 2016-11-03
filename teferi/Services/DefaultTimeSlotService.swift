import Foundation

class DefaultTimeSlotService : TimeSlotService
{
    //MARK: Fields
    private var callbacks = [(TimeSlot) -> ()]()
    
    func add(timeSlot: TimeSlot)
    {
        //The previous TimeSlot needs to be finished before a new one can start
        //guard endPreviousTimeSlot(atDate: timeSlot.startTime) else { return false }
        
    }
    
    func getTimeSlots(forDay day: Date) -> [TimeSlot]
    {
        return []
    }
    
    func update(timeSlot: TimeSlot, withCategory category: Category)
    {
        
    }
    
    func getLastTimeSlot() -> TimeSlot
    {
        return TimeSlot()
    }
    
    func subscribeToTimeSlotChanges(_ callback: @escaping (TimeSlot) -> ())
    {
        self.callbacks.append(callback)
    }
}
