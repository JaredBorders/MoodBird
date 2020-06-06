//
//  RootViewController.swift
//  MoodBird
//
//  Created by Jared Borders on 6/4/20.
//  Copyright © 2020 Jared Borders. All rights reserved.
//

import UIKit
import CoreML
import SwifteriOS

class RootViewController: UIViewController {
    
    // Instantiation using Twitter's OAuth Consumer Key and secret
    let swifter = Swifter(consumerKey: K.consumerAPIKey, consumerSecret: K.secretAPIKey)
    
    @IBOutlet var sentimentLabel: UILabel!
    @IBOutlet var textField: UITextField!
    
    let sentimentClassifier = TweetSentimentClassifier()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.attributedPlaceholder = NSAttributedString(string: "Hashtag, Name, Company, etc.",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    @IBAction func predictPressed(_ sender: UIButton) {
        if let searchtext = textField.text {
            fetchTweets(for: searchtext)
        }
    }
    
    func fetchTweets(for searchtext: String) {
        swifter.searchTweet(using: searchtext, lang: "en", count: 100, tweetMode: .extended, success: { (results, metadata) in
            
            var tweets = [TweetSentimentClassifierInput]()
            
            for i in 0..<100 {
                if let tweet = results[i]["full_text"].string {
                    let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                    tweets.append(tweetForClassification)
                }
            }
            
            self.makePredictions(for: tweets)
            
        }) { (error) in
            print("Error w/ twitter API request")
        }
        
    }
    
    func makePredictions(for tweets: [TweetSentimentClassifierInput]) {
        
        do {
            
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for prediction in predictions {
                let sentiment = prediction.label
                
                if sentiment == "Pos" { sentimentScore += 1 }
                else if sentiment == "Neg" { sentimentScore -= 1 }
            }
            
            updateUI(score: sentimentScore)
            
        } catch { print(error) }
        
    }
    
    func updateUI(score: Int) {
        sentimentLabel.text = String(score)
        // Doesn't work well bc model is not very accurate...
        //                    switch score {
        //                    case 20 ... 100:
        //                        sentimentLabel.text = "😁"
        //                    case 10 ..< 20:
        //                        sentimentLabel.text = "🙂"
        //                    case -10 ..< 10:
        //                        sentimentLabel.text = "😐"
        //                    case -20 ..< -10:
        //                        sentimentLabel.text = "☹️"
        //                    case -100 ..< -20:
        //                        sentimentLabel.text = "🤢"
        //                    default:
        //                        break
        //                    }
    }
    
}


