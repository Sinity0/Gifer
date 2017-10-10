//
//  Utils.swift
//  Gifer
//
//  Created by Niar on 9/27/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import UIKit

enum Result<Value> {
    case success(Value, Int)
    //case paginationCount(Int)
    case failure(Error)
}

enum FeedType {
    case trending, search
}

extension UIViewController {
    func showAlert(_ message: String) -> UIAlertController {
        let alertController = UIAlertController(title: "Gifer", message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(confirm)
        return alertController
    }
}
