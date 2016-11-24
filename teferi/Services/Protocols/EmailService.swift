//
//  EmailService.swift
//  teferi
//
//  Created by Nicholas Lash on 11/24/16.
//  Copyright © 2016 Toggl. All rights reserved.
//

import UIKit

protocol EmailService
{
    func composeEmail(recipients: [String], subject: String, body: String, logURL: URL?, parentViewController viewController: UIViewController)
}
