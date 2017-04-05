//
//  ChartView.swift
//  Rytmus
//
//  Created by Vojtech Rinik on 16/01/16.
//  Copyright © 2016 Vojtech Rinik. All rights reserved.
//

import UIKit
import WatchConnectivity

class ChartView: UIView, WCSessionDelegate {
    var values = [(Float, NSDate)]() {
        didSet {
            self.frameStart = NSDate()
            setNeedsDisplay()
        }
    }

    var count: Int = 1
    var frameStart: NSDate?
    var startTime: NSDate?
    var beatDuration: NSTimeInterval?

    var timer: NSTimer?
    var beatTimer: NSTimer?

    override init(frame: CGRect) {
        super.init(frame: frame)


    }

    func setupTimer(sender: AnyObject?) {
        self.timer?.invalidate()

        if startTime == nil {
            self.timer = NSTimer.schedule(delay: 1, handler: self.setupTimer)
            return
        }

        let start = startTime!

        let session = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()

        do {
            try session.updateApplicationContext([
                "start": start,
                "beatDuration": beatDuration!
                ])
        } catch {
            Swift.print("Failed sending \(error)")
        }

        var beatTime = start

        while beatTime.timeIntervalSinceDate(NSDate()) < 0 {
            beatTime = beatTime.dateByAddingTimeInterval(self.beatDuration!)
        }

        print("Next beat time: \(beatTime)")

        NSTimer.schedule(delay: beatTime.timeIntervalSinceDate(NSDate())) { _ in
            self.beatTimer?.invalidate()
            self.beatTimer = NSTimer.schedule(repeatInterval: self.beatDuration!, handler: { _ in
                self.backgroundColor = UIColor.blackColor()
                Swift.print("BEAT")
                NSTimer.schedule(delay: 0.05, handler: { (_) -> Void in
                    self.backgroundColor = UIColor.whiteColor()
                })
            })
        }



//        self.beatTimer = NSTimer(fireDate: beatTime, interval: 0, target: self, selector: "makeBeat", userInfo: nil, repeats: false)
//        self.beatTimer.


//
////        Swift.print("Current time: \(NSDate().timeIntervalSince1970*1000)")
//        var delay = (next.timeIntervalSince1970-NSDate().timeIntervalSince1970) / 1000
////        Swift.print("Scheduling next beat: \(self.beatDuration)")
//
//        while delay < 0 {
//            delay += self.beatDuration!
//        }
//
//        print("Beat in: \(delay)")
//
//
//
//        NSTimer.schedule(delay: delay) { _ in
//            self.beatTimer?.invalidate()
//            self.beatTimer = NSTimer.schedule(repeatInterval: self.beatDuration!) { _ in
//                
//            }
//        }

        self.timer = NSTimer.schedule(delay: 10) { (_) -> Void in
            self.setupTimer(nil)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.timer = NSTimer.schedule(delay: 1, handler: self.setupTimer)
    }


    override func drawRect(rect: CGRect) {
        let w = rect.size.width / CGFloat(count)

        let ctx = UIGraphicsGetCurrentContext()
        UIColor.blueColor().set()

        CGContextScaleCTM(ctx, 1, -1)
        CGContextTranslateCTM(ctx, 0, -self.bounds.size.height)

        let values = self.values


        if values.count <= 1 {
            return
        }

        var values2 = [(Float, NSDate)]()

        var lastSaved = 1

        for var i = 1; i < values.count; i++ {
            let (value, date) = values[i]
            let (previous, _) = values[i-1]
            let diff = value - previous

            if diff > 1 && (i - lastSaved) > 10 {
                values2.append((diff, date))
                lastSaved = i
            } else {
                values2.append((0, date))
            }
        }



        var peaks = [(Int, NSDate)]()

        for var i = 0; i < values2.count; i++ {
            let (value, date) = values2[i]
            if value > 0 {
                peaks.append((i, date))
            }
        }



//        print("Peaks: \(peaks.count)")

        if peaks.count > 0 {
            let (_, ref) = peaks[0]
//            let ref = peaks[0].date

            for peak in peaks {
                let (frame, date) = peak
                let diff = date.timeIntervalSinceDate(ref)
//                print("    \(frame) - \(diff)")
            }
        }

        var counts = [Int: Int]()
        var offsets = [Int: Int]()
        var dates = [Int: [NSDate]]()
        var lengths = [Int: [NSTimeInterval]]()

        for var i = 0; i < peaks.count - 5; i++ {
            for var j = 0; j < 5; j++ {
                let (frame, date) = peaks[i]
                let (otherFrame, otherDate) = peaks[i+j]

                let interval = otherFrame - frame
                if interval > 0 {
                    counts[interval] = counts[interval] ?? 0
                    counts[interval]! += 1

                    if offsets[interval] == nil {
                        offsets[interval] = frame
                    }

//                    if dates[interval] == nil {
                    if dates[interval] == nil {
                        dates[interval] = [NSDate]()
                    }

                    dates[interval]!.append(date)

                    if lengths[interval] == nil {
                        lengths[interval] = [NSTimeInterval]()
                    }

                    lengths[interval]!.append(otherDate.timeIntervalSinceDate(date))

                }

            }
        }


        var counts2 = counts.map { key, value in
            return (key, value)
        }


        // Double the array by multiplying every member by 2

        // Sort
        var counts3 = counts2.sort { item1, item2 in
            let (_, count1) = item1
            let (_, count2) = item2

            return count1 > count2
        }

        counts3 = Array(counts3.prefix(10))

//        print("Counts: \(counts3)")

        if let winner = counts3.first {
            let (interval, _) = winner

//            let offset = offsets[interval]
//            let timeOffset = self.frameStart!.dateByAddingTimeInterval(Double(Float(Float(offset!) * 23) / Float(1000)))
            let timeOffset = dates[interval]!.last

//            print("Dates: \(dates[interval])")

            self.startTime = timeOffset




//            print("Time offset: \(timeOffset)")

            var sum: Double = 0

            for len in lengths[interval]! {
                sum += len
            }

            var seconds = sum / Double(lengths[interval]!.count)

//            var seconds = lengths[interval]![0]

//            print("All lengths: \(lengths[interval])")

//            print("Duration: \(seconds)")

            var bpm = 60 / seconds

            if bpm < 90 {
                bpm = bpm * 2
                seconds = seconds / 2

                if bpm < 90 {
                    bpm = bpm * 2
                    seconds = seconds / 2
                }
            }

            if bpm > 180 {
                bpm = bpm/2
            }

            let beatDuration = Double(seconds)

//            print("Beat duration: \(beatDuration)")
//            print("BPM: \(bpm)")

            if self.beatDuration != beatDuration {
                self.beatDuration = beatDuration
            } else {
                self.beatDuration = beatDuration
            }

        }

//        print(values2)

//        var distances = [Int: Int]()

//        for var i = 5; i < values2.count; i++ {
//            if values2[i] > 0 {
//                var found = 0
//                var k = i
//                while k > 0 && found < 5 {
//                    if values2[k] > 0 {
//                        distances[k] = distances[k] ?? 0
//                        distances[k]! += 1
//                        found += 1
//                    }
//
//                    k--
//                }
//            }
//        }

//        Swift.print("Distances: \(distances)")
//        Swift.print("")
//        Swift.print("")


        for var i = 0; i < values2.count; i++ {
            let (value, _) = values2[i]
            let rect = CGRectMake(w * CGFloat(i), 0, w, CGFloat(value) * 20)
            //            Swift.print("rect: \(rect)")
            CGContextFillRect(ctx, rect)

        }
    }

}










//
//  NSTimer+Additions.swift
//  Pomodoro X
//
//  Created by Vojtech Rinik on 10/12/15.
//  Copyright © 2015 Vojtech Rinik. All rights reserved.
//

import Foundation


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
