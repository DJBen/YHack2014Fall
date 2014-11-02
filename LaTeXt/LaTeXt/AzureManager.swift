//
//  AzureManager.swift
//  LaTeXt
//
//  Created by Sihao Lu on 11/1/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit

class AzureManager: NSObject {
    
    var client: MSClient!
    
    class var sharedManager : AzureManager {
        struct Static {
            static let instance : AzureManager = AzureManager()
        }
        return Static.instance
    }
    
}

extension NSError {
    func isInvalidSyntaxError() -> Bool {
        return self.code == 419
    }
}