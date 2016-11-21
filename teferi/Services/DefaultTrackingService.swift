import CoreLocation
import CoreMotion
import UIKit
import Foundation

/// Default implementation of the TrackingService.
class DefaultTrackingService : TrackingService
{
    // MARK: Fields
    private let notificationText = "NotificationText".translate()
    private let notificationTimeout = TimeInterval(20 * 60)
    
    private let loggingService : LoggingService
    private var settingsService : SettingsService
    private let timeSlotService : TimeSlotService
    private let notificationService : NotificationService
    
    //MARK: Init
    init(loggingService: LoggingService,
         settingsService: SettingsService,
         timeSlotService: TimeSlotService,
         notificationService: NotificationService)
    {
        self.loggingService = loggingService
        self.settingsService = settingsService
        self.timeSlotService = timeSlotService
        self.notificationService = notificationService
    }
    
    //MARK:  TrackingService implementation
    func onNewLocation(_ location: CLLocation)
    {
        let currentLocationTime = location.timestamp
        
        guard let previousLocationTime = self.settingsService.lastLocationDate else
        {
            self.settingsService.setLastLocationDate(currentLocationTime)
            return
        }
        
        guard currentLocationTime > previousLocationTime else { return }
        
        self.settingsService.setLastLocationDate(currentLocationTime)
        
        let currentTimeSlot = self.timeSlotService.getLast()
        
        let difference = currentLocationTime.timeIntervalSince(previousLocationTime)
        if (difference / 60) < 25.0
        {
            if currentTimeSlot.category == .unknown
            {
                self.timeSlotService.update(timeSlot: currentTimeSlot, withCategory: .commute)
            }
        }
        else
        {
            if currentTimeSlot.startTime < previousLocationTime
            {
                let intervalTimeSlot = TimeSlot(withStartDate: previousLocationTime)
                self.timeSlotService.add(timeSlot: intervalTimeSlot)
            }
            
            let newTimeSlot = TimeSlot(withStartDate: currentLocationTime)
            self.timeSlotService.add(timeSlot: newTimeSlot)
        }
        
        self.notificationService.unscheduleAllNotifications()
        
        let notificationDate = Date().addingTimeInterval(self.notificationTimeout)
        self.notificationService.scheduleNotification(date: notificationDate, message: notificationText)
    }
}
