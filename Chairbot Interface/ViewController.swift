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

    @IBAction func clearTapped() {
        let theDrawView: DrawView = drawView as! DrawView
        theDrawView.lines = []
        theDrawView.setNeedsDisplay()
    }
    
    @IBOutlet weak var drawUIView: UIView!
    @IBOutlet weak var executeButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    @IBAction func sendLines() {
        let theDrawView: DrawView = drawView as! DrawView
        

        var pathPoints = [Any]()
        
        for line in theDrawView.lines {
           pathPoints.append([line.start.x, line.start.y])
        }
 
        let json: [String: Any] = [ "path": pathPoints ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
       // var request = URLRequest(url: URL(string: "http://ubuntu-cdr.local:5000/path")!)
        
        var request = URLRequest(url: URL(string: "http://localhost:5000/path")!)
        
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: String] {
                print(responseJSON["status"]!)
                if responseJSON["status"] == "SUCCESS" {
                    self.executeButton.isHidden = true
                    self.clearButton.isHidden = true
                    self.stopButton.isHidden = false
                    self.drawUIView.isUserInteractionEnabled = false
                }
            }
        }
        task.resume()
    }
    
    @IBAction func stopChairbot(_ sender: Any) {
        // var request = URLRequest(url: URL(string: "http://ubuntu-cdr.local:5000/stop")!)
        var request = URLRequest(url: URL(string: "http://localhost:5000/stop")!)
        
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
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: String] {
                print(responseJSON)
                if responseJSON["status"] == "SUCCESS" {
                    self.executeButton.isHidden = false
                    self.clearButton.isHidden = false
                    self.stopButton.isHidden = true
                    self.drawUIView.isUserInteractionEnabled = true
                }
            }
        }
        
        task.resume()

    }

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

