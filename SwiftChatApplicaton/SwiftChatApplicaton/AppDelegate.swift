//
//  AppDelegate.swift
//  SwiftChatApplicaton
//
//  Created by Antonio on 09/06/2015.
//  Copyright (c) 2015 Antonio. All rights reserved.
//

import UIKit
import CoreData


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, XMPPRosterDelegate{

    var window: UIWindow?
    var chatInformation = [NSManagedObject]();
    var chatServer : NSString = "chat.nudj.co";
    
    //XMPP ATTRIBUTES
    var xmppStream : XMPPStream?;
    var xmppReconnect :XMPPReconnect?;
    var xmppRosterStorage :XMPPRosterCoreDataStorage?;
    var xmppRoster :XMPPRoster?;
    var xmppvCardStorage :XMPPvCardCoreDataStorage?;
    var xmppvCardTempModule :XMPPvCardTempModule?;
    var xmppvCardAvatarModule :XMPPvCardAvatarModule?;
    var xmppCapabilitiesStorage :XMPPCapabilitiesCoreDataStorage?;
    var xmppCapabilities :XMPPCapabilities?;
    var xmppMessageArchivingStorage :XMPPMessageArchivingCoreDataStorage?;
    var xmppMessageArchivingModule  :XMPPMessageArchiving?;

    let jabberUsername = "5@chat.nudj.co";
    let jabberPassword = "SKozZ3AuQLUTcHm8FVxSFjxuC3wniMzczWN6g9n5LU6dnAarxXzlPOXIPwtT";
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.setupStream()
        
        println(chatServer)
        println("printing this things count -> \(chatInformation.count)");
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        //self.disconnect(false)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
        // WILL RECONNECT TO THE CHAT SERVER
        //if (!self.connect())
        //{
          //  println("NOT Connected to chat client !!!")
        //}
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        
        // DISCONECT FROM THE CHAT SERVER
       // self.disconnect(false);
       // self.teardownStream();
    }

    
    
   // MARK: XMPP allocation and set up
    
   func setupStream() {
    
    // SET UP ALL XMPP MODULES
    // Setup vCard support
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
    xmppStream = XMPPStream();

    xmppReconnect = XMPPReconnect();
    xmppRosterStorage = XMPPRosterCoreDataStorage();
    xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage);
   
    xmppvCardStorage = XMPPvCardCoreDataStorage.sharedInstance();
    xmppvCardTempModule = XMPPvCardTempModule(withvCardStorage:xmppvCardStorage);
    
    xmppvCardAvatarModule = XMPPvCardAvatarModule(withvCardTempModule:xmppvCardTempModule);

    xmppCapabilitiesStorage = XMPPCapabilitiesCoreDataStorage.sharedInstance();
    xmppCapabilities = XMPPCapabilities(capabilitiesStorage: xmppCapabilitiesStorage);
    
    // SET UP ALL XMPP MODULES
    xmppRoster!.autoFetchRoster = true;
    xmppRoster!.autoAcceptKnownPresenceSubscriptionRequests = true;
    
    xmppCapabilities!.autoFetchHashedCapabilities = true;
    xmppCapabilities!.autoFetchNonHashedCapabilities = true;
    
    xmppMessageArchivingStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance();
    xmppMessageArchivingModule = XMPPMessageArchiving(messageArchivingStorage: xmppMessageArchivingStorage);
    xmppMessageArchivingModule!.clientSideMessageArchivingOnly = true;
    
    
    // Activate xmpp modules
    xmppReconnect!.activate(xmppStream);
    xmppRoster!.activate(xmppStream);
    xmppvCardTempModule!.activate(xmppStream);
    xmppvCardAvatarModule!.activate(xmppStream);
    xmppCapabilities!.activate(xmppStream);
    xmppMessageArchivingModule!.activate(xmppStream);
    
    xmppStream!.addDelegate(self, delegateQueue: dispatch_get_main_queue());
    xmppRoster!.addDelegate(self, delegateQueue:dispatch_get_main_queue());
    xmppMessageArchivingModule!.addDelegate(self, delegateQueue:dispatch_get_main_queue());
    
    }
    
    // MARK: XMPP Dealloc
    
    func teardownStream(){
    
    // REMOVE FROM MEMORY
    xmppStream!.removeDelegate(self);
    xmppRoster!.removeDelegate(self);
    
    xmppReconnect!.deactivate();
    xmppRoster!.deactivate();
    xmppvCardTempModule!.deactivate();
    xmppvCardAvatarModule!.deactivate();
    xmppCapabilities!.deactivate();
    
    xmppStream!.disconnect();
    
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesStorage = nil;
        
    }
    
    // MARK: XMPP protocols and configs

    func managedObjectContext_roster () -> NSManagedObjectContext! {
    
        return xmppRosterStorage!.mainThreadManagedObjectContext;
        
    }
    
    func managedObjectContext_capabilities () -> NSManagedObjectContext!{
    
        return xmppCapabilitiesStorage!.mainThreadManagedObjectContext;
        
    }
    
    
    func goOnline()
    {
    
    var presence : XMPPPresence = XMPPPresence()
    xmppStream!.sendElement(presence);
        
    }
    
    func goOffline()
    {
    
    var presence : XMPPPresence = XMPPPresence(type: "unavailable");
    xmppStream!.sendElement(presence);
    
    }
    
    
    func connect() -> Bool{
    
    let prefs = NSUserDefaults.standardUserDefaults();
        
    // getting the token
    let token : NSString = prefs.stringForKey("token")!;
        
    if(token.length > 0){
  

        if (!xmppStream!.isDisconnected()) {
            
            self.goOnline();
            
            return true;
            
        }

//        let jabberUsername = NSUserDefaults.standardUserDefaults().stringForKey("userJabberID");
//        let jabberPassword = NSUserDefaults.standardUserDefaults().stringForKey("userJabberPassword");
        
        println("Connecting to chat server with: \(jabberUsername) - \(jabberPassword)");
        
        if (jabberUsername.isEmpty || jabberPassword.isEmpty) {
            
            return false;
            
        }
        
        
        xmppStream!.myJID = XMPPJID.jidWithString(jabberUsername);
        var error: NSError?;
        
        if (!xmppStream!.connectWithTimeout(XMPPStreamTimeoutNone, error: &error)) {
            
            let alertView = UIAlertView(title: "Error", message:"Can't connect to the chat server \(error!.localizedDescription)", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            
            return false;
            
        }
        
        return true;
        
    }else{
        
        return false
        
    }
        
    
    }
    
    
    func disconnect(query:Bool){
    let prefs = NSUserDefaults.standardUserDefaults();
    
    // getting the token
    let token = prefs.stringForKey("token");
    
    self.goOffline();
    
    if(query){
    xmppStream!.disconnect();
    }
        
    }

    
    func xmppStreamDidConnect(sender :XMPPStream) {
    
    var error : NSError?;
    //let jabberPassword = NSUserDefaults.standardUserDefaults().stringForKey("userJabberPassword");
    

        if (!self.xmppStream!.authenticateWithPassword(jabberPassword, error: &error))
        {
            println("Error authenticating: \(error)");
        }
    
    
    }
    
    func xmppStreamDidAuthenticate(sender :XMPPStream) {
    
    self.goOnline();
    
    println("Has CONNECTED TO JABBER");
    
    }


    func xmppStream(sender:XMPPStream, didNotAuthenticate error:NSXMLElement){
    
    println("Could not authenticate Error \(error)");
    
    }
    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "UnifiedLtd.SwiftChatApplicaton" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("SwiftChatApplicaton", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SwiftChatApplicaton.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

