import UIKit
@testable import teferi

class MockFeedbackService: FeedbackService
{
    func composeEmail(recipients: [String], subject: String, body: String, logURL: URL?, parentViewController viewController: UIViewController)
    {
        
    }
}
