import UIKit
@testable import teferi

class MockFeedbackService: FeedbackService
{
    var hasStartedFeedback: Bool
    {
        get
        {
            return false
        }
        set { }
    }
    
    var logURL: URL?
    {
        return nil
    }
    
    func composeFeedback(parentViewController: UIViewController)
    {
        
    }
}
