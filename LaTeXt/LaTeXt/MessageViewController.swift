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
    private var loginButton: UIBarButtonItem!
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.\
        let client = AzureManager.sharedManager.client
        loginWithCompletion { (user, error) -> Void in
            if error != nil {
                return
            }
            if user != nil {
                let message: [String: AnyObject] = ["content": "My fucking equation is $\\int_{i=1}^{k} nimabi(x)$, what do you think? $fff(x)$ or $shabi(x)$?", "recipient": "2"]
                let messageTable = client.tableWithName("Message")
                let codeTable = client.tableWithName("code")
                messageTable.insert(message, completion: { (insertedItem, error) -> Void in
                    println("INS: \(insertedItem): \(error)")
                    let messageID: String = insertedItem["id"] as String
                    codeTable.readWithPredicate(NSPredicate(format: "message_id == %@", messageID), completion: { (items, totalCount, error) -> Void in
                        if error != nil {
                            println("READ: \(error)")
                            return
                        }
                        println("READ \(totalCount): \(items)")
                    })
                })
            }
        }
    }
    
    private func loginWithCompletion(completion: (MSUser?, NSError?) -> Void) {
        let client = AzureManager.sharedManager.client
        if client.currentUser == nil {
            client.loginWithProvider("windowsazureactivedirectory", controller: self, animated: true, completion: { (user, error) -> Void in
                completion(user, error)
                println("\(user): \(error)")
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func activityButtonTapped(sender: UIButton!) {
        LaTeXRenderer.sharedRenderer.fetchPreviewImageForLaTeX("\(textField.text)", fetchBlock: { (image, error) -> Void in
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
        let message = XHMessage(text: text, sender: client.currentUser.userId, timestamp: date)
        
    }
}
