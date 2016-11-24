//
//  DefaultiOSEmailService.swift
//  teferi
//
//  Created by Nicholas Lash on 11/24/16.
//  Copyright © 2016 Toggl. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class DefaultiOSEmailService: NSObject, EmailService, MFMailComposeViewControllerDelegate
{
    override init()
    {
        super.init()
    }
    
    func composeEmail(recipients: [String], subject: String, body: String, logURL: URL?, parentViewController viewController: UIViewController) {
        
        //Check if email is configured on the device
        guard MFMailComposeViewController.canSendMail() else
        {
            let alert = UIAlertController(title: "Oops! Seems like your email account is not set up.", message: "Go to “Settings > Mail > Add Account” to set up an email account or send us your feedback to support@toggl.com", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            viewController.present(alert, animated: true, completion: nil)
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(recipients)
        composeVC.setSubject(subject)
        composeVC.setMessageBody(body, isHTML: false)
        
        //Try to attach log file, if it exists
        if let logURL = logURL, let data = try? Data(contentsOf: logURL)
        {
            composeVC.addAttachmentData(data, mimeType: "text/xml", fileName: "superday.log")
        }
        
        viewController.present(composeVC, animated: true)
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
        if error != nil
        {
            let alertTitle = "Sorry. Can’t send email."
            let alertMessage = "You’re offline. Please connect to the internet and try again."
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            
            controller.present(alert, animated: true)
        }
        controller.dismiss(animated: true)
    }
}
