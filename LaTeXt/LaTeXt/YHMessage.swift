//
//  YHMessage.swift
//  LaTeXt
//
//  Created by Sihao Lu on 11/2/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit

class YHMessage: XHMessage, Printable {
    var dictionary: [String: AnyObject]
    
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
    
    init(text: String, recipient theRecipient: String?) {
        dictionary = [String: AnyObject]()
        super.init(text: text, sender: AzureManager.sharedManager.client.currentUser.userId, timestamp: NSDate())
        self.recipient = theRecipient ?? ""
        dictionary["recipient"] = self.recipient
    }

    required init(coder aDecoder: NSCoder) {
        dictionary = [String: AnyObject]()
        super.init(coder: aDecoder)
    }
    
    override var description: String {
        get {
            return "YHMessage<Recipient=\(recipient), Content=\(text)>"
        }
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

func ==(lhs: YHDeliveredMessage, rhs: YHDeliveredMessage) -> Bool {
    return lhs.messageID == rhs.messageID
}

class YHDeliveredMessage: YHMessage, Equatable {
    var components = [YHMessageComponent]()
    var messageID: String!
    var latex: [AnyObject]!

    init?(rawDataDict: [String: AnyObject]) {
        super.init(text: "", recipient: nil)
        messageID = rawDataDict["id"] as? String
        let content = rawDataDict["content"] as? String
        let userId = rawDataDict["recipient"] as? String
        let senderHere = rawDataDict["sender"] as? String
        if content == nil || userId == nil || messageID == nil || senderHere == nil {
            return nil
        }
        text = content!
        recipient = userId!
        sender = senderHere!
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addComponentFromRawData(componentRawData: [[String: AnyObject]]) {
        var componentsToAdd = [YHMessageComponent]()
        for rawDataDict in componentRawData {
            let isCode = rawDataDict["code"] as? Bool
            let content = rawDataDict["content"] as? String
            let messageID = rawDataDict["message_id"] as? String
            let order = rawDataDict["order"] as? Int
            
            if isCode == nil || content == nil || messageID == nil || order == nil || (messageID != nil && messageID! != self.messageID) {
                continue
            }
            
            componentsToAdd.append(YHMessageComponent(order: order!, content: content!, isCode:isCode!))
            components = componentsToAdd
        }
    }
    
    func generateLaTeX(completion: ((latex: [AnyObject]?, error: NSError?) -> Void)?) {
        var orderDict = [String: Int]()
        let group = dispatch_group_create()
        var latex = [AnyObject]()
        for (index, _) in enumerate(components) {
            latex.append("")
        }
        for (index, component) in enumerate(components) {
            if !component.isCode {
                latex[index] = component.content
                continue
            }
            dispatch_group_enter(group)
            orderDict[component.content] = index
            LaTeXRenderer.sharedRenderer.fetchPreviewImageForLaTeX(component.content, fetchBlock: { (str, image, error) -> Void in
                dispatch_group_leave(group)
                if error != nil {
                    println("Error generate latex \(error)")
                    completion?(latex: nil, error: error)
                    return
                }
                latex[orderDict[str]!] = image!
            })
            dispatch_group_notify(group, dispatch_get_main_queue()) {
                self.latex = latex
                completion?(latex: latex, error: nil)
            }
        }

    }
    
    override var description: String {
        get {
            return "YHDeliveredMessage<MessageID=\(messageID), Recipient=\(recipient), Sender=\(sender) Content=\(text), #Components=\(components.count)>"
        }
    }
}