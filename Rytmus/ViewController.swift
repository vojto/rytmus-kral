//
//  ViewController.swift
//  Rytmus
//
//  Created by Vojtech Rinik on 16/01/16.
//  Copyright © 2016 Vojtech Rinik. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController {
    var values = [(Float, NSDate)]()
    var count = 2000

    @IBOutlet weak var chart: ChartView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let session = WCSession.defaultSession()
        session.activateSession()
        print("Session available")

        chart.count = self.count
        // Do any additional setup after loading the view, typically from a nib.

        
        let recorder = Recorder()

        recorder.onSample = { volume, date in

            let value = 100 + volume

            self.values.append((value, date))

            while self.values.count > self.count {
                self.values.removeFirst()
            }

            dispatch_async(dispatch_get_main_queue()) { _ in
                self.chart.values = self.values
            }
        }

        recorder.record()

        /*


}]; 
        */

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

