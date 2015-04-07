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

    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    let blueColor = UIColor(red: 51/255, green: 73/255, blue: 96/255, alpha: 1.0)
    
    // MARK: view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Notification center
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged:"),
            name: WearableServiceChangedStatusNotification, object: nil)

        // Discovery wearable
        wearable
    }
    
    // MARK: on connection change
    func connectionChanged(notification: NSNotification) {
        let userInfo = notification.userInfo as [String: Bool]
        
        dispatch_async(dispatch_get_main_queue(), {
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    self.navigationController!.navigationBar.topItem?.title = "Conectado"
                    self.navigationController!.navigationBar.barTintColor = self.blueColor
                    self.loader.hidden = true
                    
                } else {
                    self.navigationController!.navigationBar.topItem?.title = "Buscando Wearable"
                    self.navigationController!.navigationBar.barTintColor = UIColor.grayColor()
                    self.loader.hidden = false
                }
            }
        });
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
    @IBAction func redSliderChange(slider: UISlider) {
        if let wearableService = wearable.wearableService {
            wearableService.sendCommand(String(format: "#LR0%.0f\n", slider.value))
        }
    }
    
    @IBAction func greenSliderChange(slider: UISlider) {
        if let wearableService = wearable.wearableService {
            wearableService.sendCommand(String(format: "#LG0%.0f\n", slider.value))
        }
    }
    
    @IBAction func blueSliderChange(slider: UISlider) {
        if let wearableService = wearable.wearableService {
            wearableService.sendCommand(String(format: "#LB0%.0f\n", slider.value))
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
}

