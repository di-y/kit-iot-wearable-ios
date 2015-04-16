//
//  ViewController.swift
//  Kit Iot Wearable
//
//  Created by Vitor Leal on 4/1/15.
//  Copyright (c) 2015 Telefonica VIVO. All rights reserved.
//
import UIKit
import CoreBluetooth


class ViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    let blueColor = UIColor(red: 51/255, green: 73/255, blue: 96/255, alpha: 1.0)
    var timer = NSTimer()
    
    
    // MARK: view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Notification center
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged:"),
            name: WearableServiceChangedStatusNotification, object: nil)

        // Discovery wearable
        wearable
        
        // Set timed function execution
    }
    
    // MARK: on connection change
    func connectionChanged(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: Bool]
        
        dispatch_async(dispatch_get_main_queue(), {
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    self.wearableConnected()
                    
                } else {
                    self.wearableDisconnected()
                }
            }
        });
    }
    
    // MARK: On wearable disconnection
    func wearableDisconnected() {
        // Change the title
        self.navigationController!.navigationBar.topItem?.title = "Buscando Wearable"
        // Change naviagation color
        self.navigationController!.navigationBar.barTintColor = UIColor.grayColor()
        // Show loader
        self.loader.hidden = false
        // Show content view
        self.contentView.hidden = true
        // Cancel timer
        self.timer.invalidate()
    }

    // MARK: On wearable connection
    func wearableConnected() {
        //Change the title
        self.navigationController!.navigationBar.topItem?.title = "Conectado"
        //Change naviagation color
        self.navigationController!.navigationBar.barTintColor = self.blueColor
        // Hide loader
        self.loader.hidden = true
        // Show content view
        self.contentView.hidden = false
        
        // Get the sensor values
        self.getSensorValues()
        
        // Start timer
        self.timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("getSensorValues"), userInfo: nil, repeats: true)
    }
    
    // MARK: deinit and memory warning
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: WearableServiceChangedStatusNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Slider change
    @IBAction func sliderChange(slider: UISlider) {
        if let wearableService = wearable.wearableService {
            if (slider.isEqual(redSlider)) {
                wearableService.sendCommand(String(format: "#LR0%.0f\n", slider.value))
            }
            
            if (slider.isEqual(greenSlider)) {
                wearableService.sendCommand(String(format: "#LG0%.0f\n", slider.value))
            }
            
            if (slider.isEqual(blueSlider)) {
                wearableService.sendCommand(String(format: "#LB0%.0f\n", slider.value))
            }
        }
    }
    
    
    // MARK: Button click
    @IBAction func ledOFF(sender: AnyObject) {
        if let wearableService = wearable.wearableService {
            wearableService.sendCommand("#LL0000\n")
            
            redSlider.setValue(0, animated: true)
            greenSlider.setValue(0, animated: true)
            blueSlider.setValue(0, animated: true)
        }
    }
    
    
    // MARK: Get light, temperature, accelerometer values
    func getSensorValues() {
        println("timer on ;)")
        
        if let wearableService = wearable.wearableService {
            wearableService.sendCommand("#TE0000\n")
            wearableService.sendCommand("#LI0000\n")
            wearableService.sendCommand("#AC0003\n")
        }
    }
    
    
    // MARK: Melody buttons click
    @IBAction func playMelody(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            case 0:
                if let wearableService = wearable.wearableService {
                    wearableService.sendCommand("#PM1234\n")
                }
            
            case 1:
                if let wearableService = wearable.wearableService {
                    wearableService.sendCommand("#PM6789\n")
                }
            
            case 2:
                if let wearableService = wearable.wearableService {
                    wearableService.sendCommand("#PM4567\n")
                }

            default:
                break;
        }
    }
}

