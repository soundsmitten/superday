import Foundation
import RxSwift
import UIKit

class PreiOSTenNotificationService : NotificationService
{
    //MARK: Fields
    private let loggingService : LoggingService
    private var notificationSubscription : Disposable?
    private let notificationAuthorizationObservable : Observable<Bool>
    
    //MARK: Initializers
    init(loggingService: LoggingService, _ notificationAuthorizationObservable: Observable<Bool>)
    {
        self.loggingService = loggingService
        self.notificationAuthorizationObservable = notificationAuthorizationObservable
    }
    
    //MARK: NotificationService implementation
    func requestNotificationPermission(completed: @escaping () -> ())
    {
        let notificationSettings = UIUserNotificationSettings(types: [ .alert, .badge ], categories: nil)
        
        self.notificationSubscription =
            self.notificationAuthorizationObservable
                .subscribe(onNext: { wasSet in
                    
                    guard wasSet else { return }
                    
                    completed()
                })
        
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }
    
    func scheduleNotification(date: Date, title: String, message: String)
    {
        loggingService.log(withLogLevel: .debug, message: "Scheduling message for date: \(date)")
        
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.alertTitle = title
        notification.alertBody = message
        notification.alertAction = "Superday"
        notification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func unscheduleAllNotifications()
    {
        guard let notifications = UIApplication.shared.scheduledLocalNotifications, notifications.count > 0 else
        {
            loggingService.log(withLogLevel: .warning, message: "Tried to unschedule notifications, but none are currently scheduled")
            return
        }
        
        notifications.forEach { n in UIApplication.shared.cancelLocalNotification(n)  }
    }
    
    func handleNotificationAction(withIdentifier identifier: String?)
    {
    }
}
