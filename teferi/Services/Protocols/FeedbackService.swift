import UIKit

protocol FeedbackService
{
    //Location of the log file
    var logURL : URL? { get }
    
    /**
     Begins the feedback process, showing a feedback UI
     
     - Parameter parentViewController: The viewcontroller that presents the feedback UI
     */
    func composeFeedback(parentViewController: UIViewController)
}
