import Foundation
@testable import teferi

class MockTimeSlotService : TimeSlotService
{
    //MARK: Fields
    private var newTimeSlotCallbacks = [(TimeSlot) -> ()]()
    
    //MARK: Properties
    private(set) var timeSlots = [TimeSlot]()
    private(set) var getLastTimeSlotWasCalled = false
    
    var didSubscribe : Bool
    {
        return newTimeSlotCallbacks.count > 0
    }
    
    //PersistencyService implementation
    func getLast() -> TimeSlot
    {
        getLastTimeSlotWasCalled = true
        return timeSlots.last!
    }
    
    func getTimeSlots(forDay day: Date) -> [TimeSlot]
    {
        let startDate = day.ignoreTimeComponents()
        let endDate = day.tomorrow.ignoreTimeComponents()
        
        return timeSlots.filter { t in t.startTime > startDate && t.startTime < endDate }
    }
    
    @discardableResult func add(timeSlot: TimeSlot)
    {
        if let lastTimeSlot = timeSlots.last
        {
            lastTimeSlot.endTime = timeSlot.startTime
        }
        
        timeSlots.append(timeSlot)
        newTimeSlotCallbacks.forEach { callback in callback(timeSlot) }
    }
    
    @discardableResult func update(timeSlot: TimeSlot, withCategory category: teferi.Category)
    {
        timeSlot.category = category
    }
    
    func subscribeToTimeSlotChanges(_ callback: @escaping (TimeSlot) -> ())
    {
        newTimeSlotCallbacks.append(callback)
    }
}
