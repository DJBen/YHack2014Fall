//
//  AzureManager.swift
//  LaTeXt
//
//  Created by Sihao Lu on 11/1/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit

let Mina = "Aad:1SzEks7nIjyqyx-ehKfdkiiAPPuNZttujyReRUrWzNg"
let David = "Aad:RfEKLxDnE7ABA9OOCXySYZyZEboadEScWkry7ATt-1E"

class AzureManager: NSObject {
    
    var client: MSClient!
    var deviceToken: NSData!
    
    class var sharedManager : AzureManager {
        struct Static {
            static let instance : AzureManager = AzureManager()
        }
        return Static.instance
    }
    
    func sendMessage(message: YHMessage, completion: (messageSent: YHDeliveredMessage?, error: NSError?) -> Void) {
        if client.currentUser == nil {
            let error = NSError(domain: "YHack", code: 1023, userInfo: nil)
            completion(messageSent: nil, error: error)
            return
        }
        let messageTable = client.tableWithName("Message")
        let codeTable = client.tableWithName("code")
        messageTable.insert(message.dictionary, completion: { (insertedItem, error) -> Void in
            println("Sent: \(insertedItem): \(error)")
            let deliveredMessage: YHDeliveredMessage? = YHDeliveredMessage(rawDataDict: insertedItem as [String: AnyObject])
            if deliveredMessage == nil {
//                let error = NSError(domain: "YHack", code: 319, userInfo: nil)
//                completion(messageSent: nil, error: error)
                println("Cannot parse delivered message with raw data: \(insertedItem)")
            } else {
                codeTable.readWithPredicate(NSPredicate(format: "message_id == %@", deliveredMessage!.messageID), completion: { (items, totalCount, error) -> Void in
                    if error != nil {
                        println("Delivered message component error: \(error)")
                        completion(messageSent: nil, error: error)
                        return
                    }
                    deliveredMessage!.addComponentFromRawData((items as [[String: AnyObject]]))
                    println("Delivered message: \(deliveredMessage)")
                    completion(messageSent: deliveredMessage!, error: nil)
                })
            }
        })
    }
    
    func receiveMessagesWithCompletion(completion: (messages: [YHDeliveredMessage]?, error: NSError?) -> Void) {
        let messageTable = client.tableWithName("Message")
        let query = MSQuery(table: messageTable, predicate: NSPredicate(format: "recipient == %@", client.currentUser.userId))
        query.orderByAscending("__createdAt")
        query.fetchLimit = 30
        query.includeTotalCount = true
        query.readWithCompletion { (items, totalCount, error) -> Void in
            if error != nil {
                println("Receive message error: \(error)")
                completion(messages: nil, error: error)
                return
            }
            let rawData = (items as [[String: AnyObject]])
            var messages = [YHDeliveredMessage]()
            let codeTable = self.client.tableWithName("code")
            var messageIDvsIndex = [String: Int]()
            let group = dispatch_group_create()
            for (index, rawDataDict) in enumerate(rawData) {
                let deliveredMessage: YHDeliveredMessage? = YHDeliveredMessage(rawDataDict: rawDataDict)
                if deliveredMessage != nil {
                    messages.append(deliveredMessage!)
                    messageIDvsIndex[deliveredMessage!.messageID] = index
                    dispatch_group_enter(group)
                    codeTable.readWithPredicate(NSPredicate(format: "message_id == %@", deliveredMessage!.messageID), completion: { (items, totalCount, error) -> Void in
                        if error != nil {
                            dispatch_group_leave(group)
                            return
                        }
                        let itemsDict: [[String: AnyObject]] = (items as [[String: AnyObject]])
                        if let currentMessageID = itemsDict[0]["message_id"] as? String {
                            if itemsDict.count > 0 {
                                let index = messageIDvsIndex[currentMessageID]!
                                messages[index].addComponentFromRawData(itemsDict)
                            }
                        }
                        dispatch_group_leave(group)
                    })
                } else {
                    println("Delivered message component error: \(error)")
                }
            }
            dispatch_group_notify(group, dispatch_get_main_queue()) {
                println("Receive messages \(totalCount): \(messages)")
                completion(messages: messages, error: nil)
            }
        }
    }
    
}

extension NSError {
    func isInvalidSyntaxError() -> Bool {
        return self.code == 419
    }
    
    func notLoggedInError() -> Bool {
        return self.code == 1023
    }
    
    func isParseDeliveredMessageError() -> Bool {
        return self.code == 319
    }
}