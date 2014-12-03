//
//  ViewController.swift
//  SwiftCounter
//
//  Created by Kai Ren on 12/3/14.
//  Copyright (c) 2014 Kai Ren. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //UI controls
    var timeLabel: UILabel? //the timer on the top
    var timeButtons: [UIButton]? //setting time array
    var startStopButton: UIButton? //start|stop button
    var clearButton: UIButton? //reset button
    
    var remainingSeconds: Int = 0 {
        willSet(newSeconds) {
            
            let mins = newSeconds / 60
            let seconds = newSeconds % 60
            
            timeLabel!.text = NSString(format: "%02d:%02d", mins, seconds)
            
            if newSeconds <= 0 {
                isCounting = false
                self.startStopButton!.alpha = 0.3
                self.startStopButton!.enabled = false
            } else {
                self.startStopButton!.alpha = 1.0
                self.startStopButton!.enabled = true
            }
            
        }
    }
    var isCounting: Bool = false {
        willSet(newValue) {
            if newValue {
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer:", userInfo: nil, repeats: true)
            } else {
                timer?.invalidate()
                timer = nil
            }
            setSettingButtonsEnabled(!newValue)
        }
    }
    
    var timer: NSTimer?
    
    let timeButtonInfos = [("1min", 60), ("3min", 180), ("5min", 300), ("1s", 1)]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.lightGrayColor()
        setupTimeLabel()
        setuptimeButtons()
        setupActionButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        timeLabel!.frame = CGRectMake(10, 40, self.view.bounds.size.width-20, 300)
        
        let gap = ( self.view.bounds.size.width - 10*2 - (CGFloat(timeButtons!.count) * 64) ) / CGFloat(timeButtons!.count - 1)
        for (index, button) in enumerate(timeButtons!) {
            let buttonLeft = 10 + (64 + gap) * CGFloat(index)
            button.frame = CGRectMake(buttonLeft, self.view.bounds.size.height-120, 64, 44)
        }
        
        startStopButton!.frame = CGRectMake(10, self.view.bounds.size.height-60, self.view.bounds.size.width-20-100, 44)
        clearButton!.frame = CGRectMake(10+self.view.bounds.size.width-20-100+20, self.view.bounds.size.height-60, 80, 44)
        
    }
    
    ///UI Helpers
    func setupTimeLabel() {
        timeLabel = UILabel()
        timeLabel!.text = "00:00"
        timeLabel!.textColor = UIColor.whiteColor()
        timeLabel!.font = UIFont(name: "Georgia", size: 40)
        timeLabel!.backgroundColor = UIColor.blackColor()
        timeLabel!.textAlignment = NSTextAlignment.Center
        
        self.view.addSubview(timeLabel!)
    }
    
    func setuptimeButtons() {
        
        var buttons = [UIButton]()
        for (index, (title, _)) in enumerate(timeButtonInfos) {
            
            let button: UIButton = UIButton()
            button.tag = index //index:store buttons
            button.setTitle("\(title)", forState: UIControlState.Normal)
            
            button.backgroundColor = UIColor.orangeColor()
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
            
            button.addTarget(self, action: "timeButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            
            buttons += [button]
            self.view.addSubview(button)
            
        }
        timeButtons = buttons
        
    }
    
    func setupActionButtons() {
        
        //create start/stop button
        startStopButton = UIButton()
        startStopButton!.backgroundColor = UIColor.redColor()
        startStopButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        startStopButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        startStopButton!.setTitle("Start/Stop", forState: UIControlState.Normal)
        startStopButton!.addTarget(self, action: "startStopButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(startStopButton!)
        
        
        clearButton = UIButton()
        clearButton!.backgroundColor = UIColor.redColor()
        clearButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        clearButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        clearButton!.setTitle("Reset", forState: UIControlState.Normal)
        clearButton!.addTarget(self, action: "clearButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(clearButton!)
        
    }
    
    ///Actions & Callbacks
    
    func clearButtonTapped(sender: UIButton) {
        remainingSeconds = 0
    }
    
    func timeButtonTapped(sender: UIButton) {
        let (title, seconds) = timeButtonInfos[sender.tag]
        remainingSeconds += seconds
    }
    
    func startStopButtonTapped(sender: UIButton) {
        isCounting = !isCounting
        
        if isCounting {
            createAndFireLocalNotificationAfterSeconds(remainingSeconds)
        } else {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        
    }
    func updateTimer(timer: NSTimer) {
        remainingSeconds -= 1
        
        if remainingSeconds <= 0 {
            self.isCounting = false
            self.timeLabel?.text = "00:00"
            self.remainingSeconds = 0
            
            let alert = UIAlertView()
            alert.title = "Done!"
            alert.message = ""
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        
    }
    func setSettingButtonsEnabled(enabled: Bool) {
        for button in self.timeButtons! {
            button.enabled = enabled
            button.alpha = enabled ? 1.0 : 0.3
        }
        clearButton!.enabled = enabled
        clearButton!.alpha = enabled ? 1.0 : 0.3
    }

    
    func createAndFireLocalNotificationAfterSeconds(seconds: Int) {
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let notification = UILocalNotification()
        
        let timeIntervalSinceNow =  NSNumber(integer: seconds).doubleValue
        notification.fireDate = NSDate(timeIntervalSinceNow:timeIntervalSinceNow);
        
        notification.timeZone = NSTimeZone.systemTimeZone();
        notification.alertBody = "Done!";
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification);
        
    }
    
    
}

