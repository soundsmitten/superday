import Foundation

///Service that persists data locally
protocol PersistencyService
{
    //MARK: Methods
    
    ///Returns the last saved instance of type T created.
    func getLast<T>() -> T
    
    /**
     Get objects givem a predicate.
     
     - Parameter predicate: Predicate used for filtering.
     
     - Returns: The found entities that comply to the provided predicate.
     */
    func get<T>(predicate: String) -> [ T ]
    
    /**
     Persists the provided element.
     
     - Parameter element: The element to be persisted.
     
     - Returns: A Bool indicating whether the operation suceeded or not.
     */
    @discardableResult func create<T>(_ element: T) -> Bool
    
    /**
     Updates the provided element.
     
     - Parameter timeSlot: The TimeSlots to be updated.
     
     - Parameter changes: Function that will apply the changes to the element.
     
     - Returns: A Bool indicating whether the operation suceeded or not.
     */
    @discardableResult func update<T>(_ element: T, changes: (T) -> T) -> Bool
}
