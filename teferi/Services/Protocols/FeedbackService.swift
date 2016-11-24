import UIKit

protocol FeedbackService
{
    func composeEmail(recipients: [String], subject: String, body: String, logURL: URL?, parentViewController viewController: UIViewController)
}
