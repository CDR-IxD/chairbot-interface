//
//  ViewController.swift
//  Chairbot Interface
//
//  Created by Abhay Venkatesh on 6/15/17.
//  Copyright © 2017 Stanford CDR. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    
    
    @IBOutlet var drawView: AnyObject!

    // Function that clears the path that has been drawn
    @IBAction func clearTapped() {
        let theDrawView: DrawView = drawView as! DrawView
        theDrawView.lines = []
        theDrawView.setNeedsDisplay()
    }
    
    // Button outlets
    @IBOutlet weak var drawUIView: UIView!
    @IBOutlet weak var executeButton: UIButton!
    @IBOutlet weak var greyExecuteButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var greyClearButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var greyStopButton: UIButton!
    
    // State of buttons before sending paths
    func buttonStateOne() {
        self.executeButton.isHidden = false
        self.clearButton.isHidden = false
        self.stopButton.isHidden = true
        self.greyExecuteButton.isHidden = true
        self.greyClearButton.isHidden = true
        self.greyStopButton.isHidden = false
        self.drawUIView.isUserInteractionEnabled = true
    }
    
    // Intermediary state, this is active while waiting for response
    func buttonStateTwo() {
        self.executeButton.isHidden = true
        self.clearButton.isHidden = true
        self.stopButton.isHidden = true
        self.greyExecuteButton.isHidden = false
        self.greyClearButton.isHidden = false
        self.greyStopButton.isHidden = false
        self.drawUIView.isUserInteractionEnabled = false
    }
    
    // Active state, robot in motion
    func buttonStateThree() {
        self.executeButton.isHidden = true
        self.clearButton.isHidden = true
        self.stopButton.isHidden = false
        self.greyExecuteButton.isHidden = false
        self.greyClearButton.isHidden = false
        self.greyStopButton.isHidden = true
        self.drawUIView.isUserInteractionEnabled = false
    }

    // Function to send path over to the OpenCV system
    @IBAction func sendLines() {
        
        // Default change to state two
        self.buttonStateTwo()
        
        // Draw a path
        let theDrawView: DrawView = drawView as! DrawView
        var pathPoints = [Any]()
        for line in theDrawView.lines {
           pathPoints.append([line.start.x, line.start.y])
        }
 
        // Send the path
        let json: [String: Any] = [ "path": pathPoints ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        var request = URLRequest(url: URL(string: "http://ubuntu-cdr.local:5000/path")!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            var responseString: String = ""
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: String] {
                responseString = responseJSON["status"]!
            }
            
            // Dispatch onto the main thread the UI update
            DispatchQueue.main.async {
                if responseString == "SUCCESS" {
                    self.buttonStateThree()
                } else {
                    self.buttonStateOne()
                }
            }
        }
        task.resume()
        
    }
    
    @IBAction func stopChairbot(_ sender: Any) {
        
        // Default change to state two
        self.buttonStateTwo()
        
        // Send the stop request
        var request = URLRequest(url: URL(string: "http://ubuntu-cdr.local:5000/stop")!)
        request.httpMethod = "POST"
        let json: [String: Any] = [ "path": [] ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            var responseString: String = ""
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: String] {
                responseString = responseJSON["status"]!
                // Dispatch onto the main thread the UI change
                DispatchQueue.main.async {
                    if responseString == "SUCCESS" {
                        self.buttonStateOne()
                    } else {
                        self.buttonStateThree()
                    }
                }
            }
        }
        task.resume()
    }
    
    // Prepare WKWebView for displaying the video feed
    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 9.0, *)
        {
            let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
            let date = NSDate(timeIntervalSince1970: 0)
            
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
        }
        else
        {
            var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
            libraryPath += "/Cookies"
            
            do {
                try FileManager.default.removeItem(atPath: libraryPath)
            } catch {
                print("error")
            }
            URLCache.shared.removeAllCachedResponses()
        }
        let url = NSURL (string: "http://ubuntu-cdr.local:8080/view-stream.html")
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        let request = NSURLRequest(url: url! as URL)
        webView.load(request as URLRequest)
    }
}

