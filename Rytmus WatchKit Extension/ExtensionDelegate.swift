//
//  ExtensionDelegate.swift
//  Rytmus WatchKit Extension
//
//  Created by Vojtech Rinik on 16/01/16.
//  Copyright © 2016 Vojtech Rinik. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

//        let session = WCSession.defaultSession()
//        session.delegate = self
//        session.activateSession()
    }



    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        Swift.print("extension got context")

//        NSTimer(fireDate: NSDate().dateByAddingTimeInterval(1), interval: 1, target: self, selector: "justTest", userInfo: false, repeats: false)

//        let device = WKInterfaceDevice.currentDevice()
//        device.playHaptic(.Click)

    }


    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}












extension NSTimer {
    /**
     Creates and schedules a one-time `NSTimer` instance.

     - Parameters:
     - delay: The delay before execution.
     - handler: A closure to execute after `delay`.

     - Returns: The newly-created `NSTimer` instance.
     */
    class func schedule(delay delay: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
        let fireDate = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
        return timer
    }

    /**
     Creates and schedules a repeating `NSTimer` instance.

     - Parameters:
     - repeatInterval: The interval (in seconds) between each execution of
     `handler`. Note that individual calls may be delayed; subsequent calls
     to `handler` will be based on the time the timer was created.
     - handler: A closure to execute at each `repeatInterval`.

     - Returns: The newly-created `NSTimer` instance.
     */
    class func schedule(repeatInterval interval: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
        let fireDate = interval + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
        return timer
    }
}