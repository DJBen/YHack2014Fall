//
//  MessageViewController.swift
//  LaTeXt
//
//  Created by Sihao Lu on 11/2/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit

class MessageViewController: XHMessageTableViewController {
    
    private var activityController: UIActivityViewController!
    @IBOutlet var loginButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.\
        messageInputView.inputTextView.placeHolder = "Type message here"
        let client = AzureManager.sharedManager.client
        loginWithCompletion { (user, error) -> Void in
            if error != nil {
                return
            }
            if user != nil {
                println("Logged in: \(user!.userId)")
//                let message: [String: AnyObject] = ["content": "My equation is $\\int_{i=1}^{k} g(x)$, what do you think? $f(x)$ or $k(x)$?", "recipient": Mina]
//                let messageTable = client.tableWithName("Message")
//                let codeTable = client.tableWithName("code")
//                messageTable.insert(message, completion: { (insertedItem, error) -> Void in
//                    println("INS: \(insertedItem): \(error)")
//                    let messageID: String = insertedItem["id"] as String
//                    codeTable.readWithPredicate(NSPredicate(format: "message_id == %@", messageID), completion: { (items, totalCount, error) -> Void in
//                        if error != nil {
//                            println("READ: \(error)")
//                            return
//                        }
//                        println("READ \(totalCount): \(items)")
//                    })
//                })
                
                self.loadMessages()
            }
        }
    }
    
    
    @IBAction func login(sender: UIBarButtonItem!) {
        let client = AzureManager.sharedManager.client
        if client.currentUser != nil {
            // Logged in
            sender.title = "Login"
            client.logout()
        } else {
            loginWithCompletion(nil)
        }
    }
    
    private func loginWithCompletion(completion: ((MSUser?, NSError?) -> Void)?) {
        let client = AzureManager.sharedManager.client
        if client.currentUser == nil {
            client.loginWithProvider("windowsazureactivedirectory", controller: self, animated: true, completion: { (user, error) -> Void in
                if error != nil {
                    let alertController = UIAlertController(title: "Login Error", message: "Error logging in. Please try again.", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    client.push.registerNativeWithDeviceToken(AzureManager.sharedManager.deviceToken, tags: [client.currentUser.userId], completion: { (error) -> Void in
                        if error != nil {
                            println("Error")
                        }
                    })

                    self.loginButton.title = "Logout"
                }
                completion?(user, error)
                println("\(user): \(error)")
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func activityButtonTapped(sender: UIBarButtonItem!) {
        LaTeXRenderer.sharedRenderer.fetchPreviewImageForLaTeX("\(messageInputView.inputTextView.text)", fetchBlock: { (_, image, error) -> Void in
            if error != nil {
                println("Fetch preview error")
            }
            self.activityController = UIActivityViewController(activityItems: [image!], applicationActivities: nil)
            self.activityController.completionWithItemsHandler = { activityType, success, returnedItems, error in
                println(activityType)
            }
            self.presentViewController(self.activityController, animated: true, completion: nil)
        })
    }


    // MARK: Message VC Delegate
    override func didSendText(text: String!, fromSender sender: String!, onDate date: NSDate!) {
        let client = AzureManager.sharedManager.client
        let message = YHMessage(text: text, recipient: client.currentUser.userId == David ? Mina : David)
        addMessage(message)
        messageInputView.inputTextView.text = ""
        AzureManager.sharedManager.sendMessage(message, completion: { (messageSent, error) -> Void in
            if error != nil {
                println("\(error)")
                return
            }
            self.finishSendMessageWithBubbleMessageType(.Text)
        })
    }
    
    override func shouldLoadMoreMessagesScrollToTop() -> Bool {
        return true
    }
    
    override func loadMoreMessagesScrollTotop() {
        loadMessages()
    }
    
    private func loadMessages() {
        loadingMoreMessage = true
        AzureManager.sharedManager.receiveMessagesWithCompletion { (messages, error) -> Void in
            if error != nil {
                println("\(error)")
                return
            }
            self.messages.removeAllObjects()
            for incomingMessage in messages! {
                if self.messages.indexOfObject(incomingMessage) != NSNotFound {
                    continue
                }
                incomingMessage.bubbleMessageType = .Receiving
                self.messages.addObject(incomingMessage)
            }
            
            self.loadingMoreMessage = false
            self.messageTableView.reloadData()
            self.scrollToBottomAnimated(true)
        }
    }
    
    override func didDoubleSelectedOnTextMessage(message: XHMessageModel!, atIndexPath indexPath: NSIndexPath!) {
        performSegueWithIdentifier("showDetails", sender: message)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetails" {
            let vc = (segue.destinationViewController as MessageItemViewController)
            vc.message = sender as YHDeliveredMessage
        }
    }
    
    private func test() {
//        AzureManager.sharedManager.receiveMessagesWithCompletion { (messages, error) -> Void in
//            if error != nil {
//                println("\(error)")
//                return
//            }
//            println("\(messages)")
//        }
//        AzureManager.sharedManager.sendMessage(YHMessage(text: "I'm David and exceptionally smart, $f(x) = E = mc^2$ Melissa $\\lim_{x\\to 0} \\frac{x}{\\sin x}$ Ohhh", recipient: David), completion: { (messageSent, error) -> Void in
//            if error != nil {
//                println("\(error)")
//                return
//            }
//            println("\(messageSent)")
//        })
    }
}
