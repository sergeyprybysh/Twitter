//
//  TweetViewController.swift
//  Twitter
//
//  Created by Sergey Prybysh on 10/11/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tweetText: UITextView!
    @IBOutlet weak var charsCount: UILabel!
    let maxTweetCharsCount = 280

    override func viewDidLoad() {
        super.viewDidLoad()
        tweetText.delegate = self
        tweetText.becomeFirstResponder()
        charsCount.text = String(maxTweetCharsCount)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    @IBAction func cancelTweet(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func tweet(_ sender: Any) {
        if (!tweetText.text.isEmpty) {
            TwitterAPICaller.client?.postTweet(tweet: tweetText.text, success: {
                self.dismiss(animated: true, completion: nil)
            }, failure: { (error) in
                print("Error posting a tweet: \(error)")
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            let alert = UIAlertController(title: "No text entered", message: "Please enter some text to post a tweet", preferredStyle: .alert)
            self.present(alert, animated: true)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = NSString(string: textView.text!).replacingCharacters(in: range, with: text)

        let currentCharsCount = newText.count
        charsCount.text = String(maxTweetCharsCount - currentCharsCount)
        if (currentCharsCount < maxTweetCharsCount) {
            return true
        } else {
            let maxCharsAlert = UIAlertController(title: "Max characters count reached", message: "There is a maximum of 280 characters allowed per tweet", preferredStyle: .alert)
            maxCharsAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(maxCharsAlert, animated: true, completion: nil)
            return false
        }
    }

    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        charsCount.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            charsCount.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -getKeyboardHeight(notification) - 20),
            charsCount.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}
