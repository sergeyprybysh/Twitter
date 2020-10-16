//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Sergey Prybysh on 10/7/20.
//  Copyright © 2020 Dan. All rights reserved.
//
    
import UIKit
import AlamofireImage

class HomeTableViewController: UITableViewController {
    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    let tweetRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets()

        // reload tweets
        tweetRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = tweetRefreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadTweets()
    }

    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCell
        let tweet = tweetArray[indexPath.row]

        let user = tweet["user"] as! NSDictionary
        cell.userNameLabel.text = user["name"] as? String

        let tweetContent = tweet["text"] as? String
        let attributedTweetContentString = NSMutableAttributedString(string: tweetContent ?? "")

        let entity = tweet["entities"] as! NSDictionary
        let mediaEntities = entity["media"] as? NSArray

        if let mediaEntities = mediaEntities {

            for image in mediaEntities {
                let imageUrlString = (image as! NSDictionary)["media_url_https"] as? String
                let textAttachment = NSTextAttachment()
                let imageUrl = URL(string: (imageUrlString)!)
                let imageData = try? Data(contentsOf: imageUrl!)

                if let imageData = imageData {
                    textAttachment.image = UIImage(data: imageData)
                }

                let oldWidth = textAttachment.image!.size.width;
                let scaleFactor = oldWidth / (self.view.frame.size.width - 10);
                textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
                let attrStringWithImage = NSAttributedString(attachment: textAttachment)
                attributedTweetContentString.append(attrStringWithImage)
            }
        }

        cell.tweetContent.attributedText = attributedTweetContentString

        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)  

        let data = try? Data(contentsOf: imageUrl!)
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }

        cell.setFavorite(tweet["favorited"] as! Bool)
        cell.setRetweeted(tweet["retweeted"] as! Bool)
        cell.tweetId = tweet["id"] as! Int

        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }

    @objc func loadTweets() {
        numberOfTweets = 20
        let twitterUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count": numberOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: twitterUrl, parameters: params as [String : Any], success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()

            for tweet in tweets {
                self.tweetArray.append(tweet)
            }

            self.tableView.reloadData()
            self.tweetRefreshControl.endRefreshing()
        }, failure: { (Error) in
            print("Could not retrieve tweets")
        })
    }

    func loadMoreTweets() {
        let twitterUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweets += 20
        let params = ["count": numberOfTweets]

        TwitterAPICaller.client?.getDictionariesRequest(url: twitterUrl, parameters: params as [String : Any], success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()

            for tweet in tweets {
                self.tweetArray.append(tweet)
            }

            self.tableView.reloadData()
        }, failure: { (Error) in
            print("Could not retrieve tweets")
        })
    }
}
