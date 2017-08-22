//
//  ViewController.swift
//  Chairbot Interface
//
//  Created by Abhay Venkatesh on 6/15/17.
//  Copyright © 2017 Stanford CDR. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var drawView: AnyObject!

    @IBAction func clearTapped() {
        let theDrawView: DrawView = drawView as! DrawView
        theDrawView.lines = []
        theDrawView.setNeedsDisplay()
    }
    
    @IBAction func sendLines() {
        let theDrawView: DrawView = drawView as! DrawView
        

        var pathPoints = [Any]()
        
        for line in theDrawView.lines {
           pathPoints.append([line.start.x, line.start.y])
        }
 
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
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        
        task.resume()
        
    }
    
    @IBAction func stopChairbot(_ sender: Any) {
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
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        
        task.resume()

    }
    
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        let videoURL = URL(string: "ws://ubuntu-cdr.local:8082/")
        let player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoView.bounds
        self.videoView.layer.addSublayer(playerLayer)
        player.play()
    }
    

}

