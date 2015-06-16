//
//  ViewController.swift
//  SwiftChatApplicaton
//
//  Created by Antonio on 09/06/2015.
//  Copyright (c) 2015 Antonio. All rights reserved.
//

import UIKit
import Foundation

class ViewController: JSQMessagesViewController {

var demoData = DemoModelData ()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var instanceOfCustomObject: CustomObject = CustomObject()
        instanceOfCustomObject.someProperty = "Hello World"
        println(instanceOfCustomObject.someProperty)
        instanceOfCustomObject.someMethod()
        
        /**
        *  You MUST set your senderId and display name
        */
        
        //lachoisgreat ant@chat.nudj.co antisgreat

        
        self.senderId = "antonio@chat.nudj.co"
        self.senderDisplayName = "Antonio "
        
        self.demoData = DemoModelData ()
    
        /**
        *  Load up our fake data for the demo
        */
        
        
        /**
        *  You can set custom avatar sizes
        */
        
        
        if (!NSUserDefaults.incomingAvatarSetting()) {
            self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        }
        
        if (!NSUserDefaults.outgoingAvatarSetting()) {
            self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        }
        
        self.showLoadEarlierMessagesHeader = false
        
        
        /**
        *  Register custom menu actions for cells.
        */

        
        /**
        *  Customize your toolbar buttons
        *
        *  self.inputToolbar.contentView.leftBarButtonItem = custom button or nil to remove
        *  self.inputToolbar.contentView.rightBarButtonItem = custom button or nil to remove
        */
        
        /**
        *  Set a maximum height for the input toolbar
        *
        *  self.inputToolbar.maximumHeight = 150;
        */
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.collectionView.collectionViewLayout.springinessEnabled = NSUserDefaults.springinessSetting()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // JSQMessagesViewController method overrides
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        /**
        *  Sending a message. Your implementation of this method should do *at least* the following:
        *
        *  1. Play sound (optional)
        *  2. Add new id<JSQMessageData> object to your data source
        *  3. Call `finishSendingMessage`
        */
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        var message = JSQMessage (senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        
        self.demoData.messages.addObject(message)
        
        self.finishReceivingMessageAnimated(true)
        
    }
    
    
    // JSQMessages CollectionView DataSource
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        var messages = self.demoData.messages.objectAtIndex(indexPath.item) as! JSQMessage
        
        return messages
    }

    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        var message = self.demoData.messages.objectAtIndex(indexPath.item) as! JSQMessage
        
        if (message.senderId == self.senderId) {
            return self.demoData.outgoingBubbleImageData;
        }
        
        return self.demoData.incomingBubbleImageData;
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        
        /**
        *  Return `nil` here if you do not want avatars.
        *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
        *
        *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        *
        *  It is possible to have only outgoing avatars or only incoming avatars, too.
        */
        
        /**
        *  Return your previously created avatar image data objects.
        *
        *  Note: these the avatars will be sized according to these values:
        *
        *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
        *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
        *
        *  Override the defaults in `viewDidLoad`
        
        */
        
        /*var message = self.demoData.messages.objectAtIndex(indexPath.item) as! JSQMessage
        
        if (message.senderId == self.senderId) {
            if (!NSUserDefaults.outgoingAvatarSetting()) {
                return nil;
            }
        }
        else {
            if (!NSUserDefaults.incomingAvatarSetting()) {
                return nil;
            }
        }*/
        
        //var dic = self.demoData.avatars as NSDictionary;
        
       // return dic.objectForKey(message.senderId) as! JSQMessageAvatarImageDataSource;
        
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        if (indexPath.item % 3 == 0) {
            var message = self.demoData.messages.objectAtIndex(indexPath.item) as! JSQMessage
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil;
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        var message = self.demoData.messages.objectAtIndex(indexPath.item) as! JSQMessage;
        
        /**
        *  iOS7-style sender name labels
        */
        if (message.senderId == self.senderId) {
            return nil;
        }
        
        if (indexPath.item - 1 > 0) {
            var previousMessage = self.demoData.messages.objectAtIndex(indexPath.item - 1) as! JSQMessage
            if (previousMessage.senderId == message.senderId) {
                return nil;
            }
        }
        
        /**
        *  Don't specify attributes to use the defaults.
        */
        
        return NSAttributedString(string: message.senderDisplayName)
    }
        
        
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        return nil
    }
    
    
    
    // UICollectionView DataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.demoData.messages.count
        
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      
        
    /**
    *  Override point for customizing cells
    */
        
    var cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
    
    /**
    *  Configure almost *anything* on the cell
    *
    *  Text colors, label text, label colors, etc.
    *
    *
    *  DO NOT set `cell.textView.font` !
    *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
    *
    *
    *  DO NOT manipulate cell layout information!
    *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
    */
    
    var msg = self.demoData.messages.objectAtIndex(indexPath.item) as! JSQMessage
    
    if (!msg.isMediaMessage) {
    
        if (msg.senderId == self.senderId) {
        cell.textView.textColor = UIColor.blackColor()
        }else {
        cell.textView.textColor = UIColor.whiteColor()
        }
            
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
       
    }
    
    return cell;
    
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        return 0.0
        
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if (indexPath.item % 3 == 0) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }
        
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        /**
        *  iOS7-style sender name labels
        */
        
        var currentMessage = self.demoData.messages.objectAtIndex(indexPath.item) as! JSQMessage
        if (currentMessage.senderId == self.senderId) {
            return 0.0
        }
        
        if (indexPath.item - 1 > 0) {
            var previousMessage = self.demoData.messages.objectAtIndex(indexPath.item - 1) as! JSQMessage
            if (previousMessage.senderId == currentMessage.senderId) {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;

    }
    
    //pragma mark - Responding to collection view tap events
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        println("Load earlier messages")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
     
        println("Tapped message bubble!")
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        
        println("Tapped cell at \(NSStringFromCGPoint(touchLocation))");
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        
         println("Tapped avatar!")
    }
    

}

