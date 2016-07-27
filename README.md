# Integrate In-app Messaging with Diuit PART2: real time chat app in iOS



In out tutorial [part 1](https://github.com/Diuit/DUChatServerDemo), we showed you how to build your own backend with integration of Diuit API server. This tutorial is going to show you how to integrate with an iOS app step by step.

## What we'll cover in this tutorial

* Integrate with Diuit API iOS framework to implement real-time communication.
* Build a basic UI for sending and receiving messages.
* How Diuit API works.



## Requirements

* Xcode 7.3+
* Swift 2.2 (default version in Xcode 7.3)
* [CocoaPods](https://cocoapods.org/)
* A backend server with integration of Diuit API. If you don't have one, you can use deploy button to build one within a minute. For more detail, check this [tutorial](https://github.com/Diuit/DUChatServerDemo).



## Getting Started

### Preparation

1. Before we start coding in Xcode, we need two session tokens which are registered by two different user serials. You can jump to step 4. if you know how to do it.
2. Use our deploy button to build a server of your own. (If you don't know how to fill the form, please check [here](https://github.com/Diuit/DUChatServerDemo#configurations))
   [![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/Diuit/DUChatServerDemo)
3. Visit `https://APP_NAME.herokuapp.com` (not `APP_NAME` is your app name deployed on Heroku), retrieve two session tokens by signing up with two different username(email). Let's name they `SESSION_A` , `SESSION_B` with user serial `USER_A` and `USER_B`.
   ![signup](http://i.imgur.com/8RVBKLH.png)
4. Keep these two tokens for later.



### Setup

1. Open your Xcode -> Create a new Project -> iOS application -> Single View Application.

2. Name it `MyFirstChat`

3. **Close the project**. Open your terminal and enter the path of the project we just created.

4. Type `pod init` to generate a new file - `Podfile`, and then open it with any text editor. (You must have CocoaPods installed)

5. Edit the content of `Podfile` like following and save:

   ```ruby
   platform :ios, '8.0'

   target 'MyFirstChat' do
     use_frameworks!
     pod 'DUMessaging'
   end
   ```

6. Execute `pod install` to install required frameworks.

7. Type `open MyFirstChat.xcworkspace` to open the project.

8. We have to set up App Id and App key in the first place. In `AppDelegate.swift`, import Diuit framework.

   ```swift
   import DUMessaging
   ```

   And then call the setter (You can get your app key and id [here](https://developer.diuit.com/dashboard))

   ```swift
   func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
   	// Add following method
       DUMessaging.set(appId: "YOUR_APP_ID", appKey: "YOUR_APP_KEY")

       return true
   }
   ```

9. Now we need to authenticat your mobile device with the session token we just retrieved (`SESSION_A` and `SESSION_B`). In `ViewController.swift`,  your app's first default first scene, add following code in your `viewDidLoad()` method.

   ```swift
   /*  ViewController.swift */
   import UIKit
   // 1. You have to import the framework too
   import DUMessaging

   class ViewController: UIViewController {

       override func viewDidLoad() {
           super.viewDidLoad()
           // 2. This method will connect to Diuit API seriver and do the authentication
           DUMessaging.authWithSessionToken("SESSION_B") { error, result in
               guard error == nil else {
                   // Error handle
                   return
               }
           }
       }
   }
   ```

10. We'd also like to give users displya names, say `WebUser` and  `MobileUser`. This can be achived easily by modifying the meta data of current user. Modify above code a little bit:

   ```swift
   /*  ViewController.swift */
   import UIKit
   // 1. You have to import the framework too
   import DUMessaging

   class ViewController: UIViewController {

       override func viewDidLoad() {
           super.viewDidLoad()
           // 2. This method will connect to Diuit API seriver and do the authentication
           DUMessaging.authWithSessionToken("SESSION_B") { error, result in
               guard error == nil else {
                   print("error:\(error!.localizedDescription)")
                   return
               }
               // 3. Update user's meta
               DUMessaging.currentUser!.updateMeta(["name":"WebUser"]) { error, user in
                   guard error == nil else {
                       // Handle error
                       return
                   }
               }
           }
       }
   }
   ```

11. Run the app. `SESSION_B`'s user meta will be set up.

12. Now we replace `SESSION_B` with `SESION_A`, and so deos the meta.

```swift
   /*  ViewController.swift */
   import UIKit
   // 1. You have to import the framework too
   import DUMessaging

   class ViewController: UIViewController {

       override func viewDidLoad() {
           super.viewDidLoad()
           // 2. This method will connect to Diuit API seriver and do the authentication
           DUMessaging.authWithSessionToken("SESSION_A") { error, result in
               guard error == nil else {
                   print("error:\(error!.localizedDescription)")
                   return
               }
               // 3. Update user's meta
               DUMessaging.currentUser!.updateMeta(["name":"MobileUser"]) { error, user in
                   guard error == nil else {
                       // Handle error
                       return
                   }
               }
           }
       }
   }
```

12. Run app again. Now both of our users have their own display names.

22. Now we need to create our first chat roo before start. Append the creating method after `updateMeta`

```swift
   DUMessaging.authWithSessionToken("SESSION_A") { error, result in
               guard error == nil else {
                   print("error:\(error!.localizedDescription)")
                   return
               }
               // 3. Update user's meta
               DUMessaging.currentUser!.updateMeta(["name":"DiuitMobileUser"]) { error, user in
                   guard error == nil else {
                       // Handle error
                       return
                   }
               }
               // 4. Create our first chat room
               DUMessaging.createDirectChatRoomWith("USER_B", meta: ["name":"My First Chat"]) { error, chat in
                   print("Successfully created chat #\(chat!.id)")
               }
           }
```

14. Run app again, and you should see the **chat id** of newly created chat room in the debug console. Record this chat id for later usage.

24. There will be only one direct chat room between two users. Therefore no matter how many times you call `createDirectChatRoomWith`, you will always get the same chat id.


### Build Basic UI & Send Messages

1. We will need three components in this tutorial: UITextView, UITextField and UIButton.

2. Drag them out from utilities side bar and add constraints for each UI element.
   ![storyboard](http://i.imgur.com/tU16RHE.png)

3. Link UITextView and UITextField with `IBOutlet`

   ```swift
   class ViewController: UIViewController {
   	@IBOutlet weak var messagesTextView: UITextView!
   	@IBOutlet weak var messageInputTextField: UITextField!
   ```

   ​
   ![IBOutlet](http://i.imgur.com/8grVDQk.png)

4. Empty messages display area in `viewDidLoad()`

   ```swift
   // 5. clear messages diplay area
   messagesTextView.text = ""
   ```

   ​

5. Add a function for formatting the messages displayed in UITextView

   ```swift
   func formatedMessageTextOf(message: DUMessage) -> String? {
       // Do not print system message
       guard message.senderUser != nil else {
           return nil
       }

       var senderTitle = ""
       if message.senderUser!.serial == DUMessaging.currentUser!.serial {
           senderTitle = "[Me] : "
       } else {
           senderTitle = "[\(message.senderUser!.meta!["name"])] : "
       }

       return senderTitle + message.data! + "\n"
   }
   ```

   ​

6. Add action for send button and link to send button

   ```swift
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
   ```

7. We are ready to send out messages now. To check the message is really sent out, we've already build a web page to communicate with your iOS app. Type `https://APP_NAME.herokusapp.com/webchat.html` in your browser, the page will need you to fill in session token and chat id. Fill `SESSION_B` and the chat id we just recorded, and then press `ENTER`.
   ![webchat](http://i.imgur.com/RFilXW4.png)

8. Type any text you want in iOS simulator and click `Send`. You can check the web page if the messages are delivered.
   ![messages received](http://i.imgur.com/OUZp4hq.png)



### Receiving Messages

1. We use NSNotification to notify of new incoming messages. Add observer in `viewDidLoad()`:

   ```swift
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
   ```

2. You need to remove NSNotification observer when the ViewController is deallocated.

   ```swift
   deinit {
       NSNotificationCenter.defaultCenter().removeObserver(self)
   }
   ```

3. You are also ready to receive messages now! Try to send some messages from the web page.
   ![send from web page](http://i.imgur.com/XFUJmBg.png)
   ![receive in iOS](http://i.imgur.com/JiaCB00.png)



### List History Messages

1. In the end, we'll show you how to list historical messages. We'd like to retrieve last 20 messages and diplay in UITextView. Listing messages is an instance method of `DUChat`, hence we add following code in completion closure of `createDirectChatRoomWith`:

   ```swift
   // 4. Create our first chat room
   DUMessaging.createDirectChatRoomWith("pofattseng@diuit.com", meta: ["name":"My First Chat"]) { error, chat in
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
   ```

   ​

2. Run the app, now you should see the old messages you just sent.
   ![historical messages](http://i.imgur.com/xMBX34p.png) 



## Where to Go from Here?

Now you know how to integrate with Diuit API mobile framework and basic operation. In tutorial PART 3, we will show you how to itegrate with our UIKit to help you complete a beautiful real time chat app effortlessly!



## Contact

This tutorial was prepared by [Diuit](http://api.diuit.com/) team. If you have any questions, feel free to [contact us](support@diuit.com) or join our [Slack channel](http://slack.diuit.com/).