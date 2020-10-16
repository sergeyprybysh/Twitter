//
//  TweetCellTableViewCell.swift
//  Twitter
//
//  Created by Sergey Prybysh on 10/7/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tweetContent: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!

    var favorited: Bool = false
    var retweeteed: Bool = false
    var tweetId: Int = -1

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setFavorite(_ isFavorited: Bool) {
        favorited = isFavorited
        if (favorited) {
            likeButton.setImage(UIImage(named: "favor-icon-red"), for: UIControl.State.normal)
        } else {
            likeButton.setImage(UIImage(named: "favor-icon"), for: UIControl.State.normal)
        }
    }

    func setRetweeted(_ isRetweeted: Bool) {
        retweeteed = isRetweeted
        if (retweeteed) {
            retweetButton.setImage(UIImage(named: "retweet-icon-green"), for: UIControl.State.normal)
        } else {
            retweetButton.setImage(UIImage(named: "retweet-icon"), for: UIControl.State.normal)
        }
    }

    @IBAction func favoriteTweet(_ sender: Any) {
        if (favorited) {
            TwitterAPICaller.client?.unfavoriteTweet(tweetId: tweetId, success: {
                self.setFavorite(false)
            }, failure: { (error) in
                print("Error unfavoriting a tweet")
            })
        } else {
            TwitterAPICaller.client?.favoriteTweet(tweetId: tweetId, success: {
                self.setFavorite(true)
            }, failure: { (error) in
                print("Error favoriting a tweet")
            })
        }
    }

    @IBAction func retweetTweet(_ sender: Any) {
        if (retweeteed) {
            TwitterAPICaller.client?.unretweetTweet(tweetId: tweetId, success: {
                self.setRetweeted(false)
            }, failure: { (error) in
                print("Error unretweeting a tweet")
            })
        } else {
            TwitterAPICaller.client?.retweetTweet(tweetId: tweetId, success: {
                self.setRetweeted(true)
            }, failure: { (error) in
                 print("Error retweeting a tweet")
            })
        }
    }
}
