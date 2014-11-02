//
//  YHMessage.swift
//  LaTeXt
//
//  Created by Sihao Lu on 11/2/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit

class YHMessage: XHMessage {
    var dictionary = [String: AnyObject]()
    
    var recipient: String = "" {
        didSet {
            dictionary["recipient"] = self.recipient
        }
    }
    
    override var text: String! {
        didSet {
            dictionary["content"] = self.text ?? ""
        }
    }
    
    init(text: String, recipient: MSUser) {
        super.init(text: text, sender: AzureManager.sharedManager.client.currentUser.userId, timestamp: NSDate())
        self.recipient = recipient.userId
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class YHMessageComponent: NSObject {
    let order: Int
    let content: String
    let isCode: Bool

    init(order: Int, content: String, isCode: Bool) {
        self.order = order
        self.content = content
        self.isCode = isCode
    }
}

class YHReceivedMessage: YHMessage {
    let components: [YHMessageComponent]
    var messageID: String

    init(componentRawData: [[String: AnyObject]]) {
        componentRawData.map {(rawDataDict: [String : AnyObject]) -> YHMessageComponent in
            rawDataDict
        }
    }
}