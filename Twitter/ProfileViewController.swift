//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Sergey Prybysh on 10/13/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    var profile: NSDictionary? {
        didSet {
            guard let profile = profile else {
                return
            }
            updateProfile(profile: profile)
        }
    }

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2;
        profileImage.layer.masksToBounds = true;
        profileImage.layer.borderWidth = 0;
        profileImage.contentMode = UIView.ContentMode.scaleAspectFill;

        loadProfile()
    }

    func loadProfile() {
        TwitterAPICaller.client?.getProfile(success: {
            [weak self] (profile: NSDictionary) in
            guard let self = self else { return }

            self.profile = profile
        }, failure: { (Error) in
            print("Error fetching a profile ", Error)
        } )
    }

    func updateProfile(profile: NSDictionary) {
        let imageUrl = URL(string: profile["profile_image_url_https"] as! String)
        let imageData = try? Data(contentsOf: imageUrl!)
        if let imageData = imageData {
            self.profileImage.image = UIImage(data: imageData)
        }

        self.nameLabel.text = profile["name"] as? String
        self.taglineLabel.text = profile["screen_name"] as? String
        let followersCount = profile["followers_count"]
        let followingCount = profile["friends_count"]
        self.followersLabel.text = "\(followersCount ?? "") following"
        self.followingLabel.text = "\(followingCount ?? "") following"
    }
}

