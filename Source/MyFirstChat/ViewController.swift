//
//  ViewController.swift
//  MyFirstChat
//
//  Created by Pofat Tseng on 2016/7/27.
//  Copyright © 2016年 Pofat Tseng. All rights reserved.
//

import UIKit
// 1. You have to import the framework too
import DUMessaging

class ViewController: UIViewController {
    @IBOutlet weak var messagesTextView: UITextView!
    @IBOutlet weak var messageInputTextField: UITextField!
    
    // MARK: properties
    var messages: [DUMessage] = [];

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 2. This method will connect to Diuit API seriver and do the authentication
        DUMessaging.authWithSessionToken("SESSION_A") { error, result in
            guard error == nil else {
                // Handle error
                print(error!.localizedDescription)
                return
            }
            
            // 3. Update user's meta
            DUMessaging.currentUser!.updateMeta(["name":"MobileUser"]) { error, user in
                guard error == nil else {
                    // Handle error
                    return
                }
            }
            
            // 4. Create our first chat room
            DUMessaging.createDirectChatRoomWith("USER_B", meta: ["name":"My First Chat"]) { error, chat in
                print("Successfully created chat #\(chat!.id)")
                // 7. List last 20 messages
                chat!.listMessages() { [unowned self] error, messages in
                    for message in messages! {
                        let messageText = self.formatedMessageTextOf(message)
                        if messageText != nil {
                            self.messagesTextView.text = messageText! + self.messagesTextView.text
                        }
                    }
                }
            }
        }
        
        // 5. clear messages diplay area
        messagesTextView.text = ""
        
        // 6. To receive incoming messages from all chat rooms
        NSNotificationCenter.defaultCenter().addObserverForName("messageReceived", object: nil, queue: NSOperationQueue.mainQueue()) { [unowned self] notif in
            // get DUMessage object
            let message = notif.userInfo!["message"] as! DUMessage
            // format message text and print it out
            let messageText = self.formatedMessageTextOf(message)
            if messageText != nil {
                self.messagesTextView.text = self.messagesTextView.text + messageText!
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func formatedMessageTextOf(message: DUMessage) -> String? {
        // // Do not print system message
        guard message.senderUser != nil else {
            return nil
        }
        
        var senderTitle = ""
        if message.senderUser!.serial == DUMessaging.currentUser!.serial {
            senderTitle = "[Me] : "
        } else {
            senderTitle = "[\(message.senderUser!.meta!["name"]!)] : "
        }
        
        return senderTitle + message.data! + "\n"
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        // only send when there's input
        guard messageInputTextField.text != "" else {
            return
        }
        
        let messageText = messageInputTextField!.text!
        // clear textField
        messageInputTextField!.text = ""
        // This method sends out text message
        DUMessaging.sendDirectText(toUser: "USER_B", text: messageText, beforeSend: nil) { [unowned self] error, message in
            let newMesage = self.formatedMessageTextOf(message!)
            if newMesage != nil {
                self.messagesTextView.text = self.messagesTextView.text + newMesage!
            }
        }
    }

}

