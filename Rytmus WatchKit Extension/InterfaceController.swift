//
//  InterfaceController.swift
//  Rytmus WatchKit Extension
//
//  Created by Vojtech Rinik on 16/01/16.
//  Copyright © 2016 Vojtech Rinik. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        let session = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()

        Swift.print("ACtivated")


    }

    var firstTimer: NSTimer?
    var beatTimer: NSTimer?

    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("got context: \(applicationContext)")


        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let start = applicationContext["start"] as! NSDate
            let beat = applicationContext["beatDuration"] as! Double

            let now = NSDate()

            var startsIn = start.timeIntervalSinceDate(now) - 0.25

            while startsIn < 0 {
                startsIn = startsIn + Double(beat)
            }

            Swift.print("Starts in: \(startsIn) seconds")

            self.firstTimer?.invalidate()
            self.firstTimer = NSTimer.schedule(delay: startsIn) { _ in
                // Play the first beat
                Swift.print("BEAT")
                WKInterfaceDevice.currentDevice().playHaptic(.Click)

                // Play some more beats
                self.beatTimer?.invalidate()
                self.beatTimer = NSTimer.schedule(repeatInterval: beat) { _ in
                    Swift.print("BEAT")
                    WKInterfaceDevice.currentDevice().playHaptic(.Click)
                }
            }
        }


    }

    func justTest(sender: AnyObject?) {
        Swift.print("Just a test")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
