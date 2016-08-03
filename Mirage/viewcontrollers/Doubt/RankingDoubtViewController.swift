//
//  RankingDoubtViewController.swift
//  Mirage
//
//  Created by Siena Idea on 11/05/16.
//  Copyright © 2016 Siena Idea. All rights reserved.
//

import UIKit

class RankingDoubtViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    var instruction = Instruction()
    var presentation = Presentation()
    var doubt = Doubt()
    var doubts  = Array<Doubt>()
    var orderedDoubts = Array<Doubt>()
    
    func tableViews() {
        tableView.delegate = self
        tableView.dataSource = self
        getDoubt()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViews()
        DefaultViewController.refreshTableView(tableView, cellNibName: StringUtil.doubtCell, view: view)
        
        refreshControl = UIRefreshControl()
        DefaultViewController.refreshControl(refreshControl, tableView: tableView)
        refreshControl.addTarget(self, action: #selector(DoubtViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        tableViews()
    }
    
    // pull to refresh
    func refresh() {
        getDoubt()
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    func getDoubt() {
        let url = Server.getRequest(Server.presentationURL+"\(instruction.id)" + Server.presentaion_bar + "\(presentation.id)" + Server.doubt)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            } else {
                let doubtJSONData = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                
                if (doubtJSONData.valueForKey(StringUtil.error) != nil) {
                    return
                } else {
                    if doubtJSONData.valueForKey(StringUtil.doubts)?.count == 0 {
                        return
                    } else {
                        let doubts =  doubtJSONData.valueForKey(StringUtil.doubts) as! NSDictionary
                        let keys = doubts.allKeys
                        
                        self.doubts = Doubt.iterateJSONArray(doubts, keys: keys)
                    }
                }
                print(doubtJSONData)
            }
        })
    
        task.resume()
        
        orderedDoubts.removeAll()
        
        var auxDoubt = Array<Doubt>()
        
        for i in 0 ..< doubts.count {
            var j = 0
            auxDoubt.insert(doubts[i], atIndex: j)
            j += 1
        }
        orderedDoubts = auxDoubt.sort({ $0.likes > $1.likes })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedDoubts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(StringUtil.cellIdentifier, forIndexPath: indexPath) as! DoubtTableViewCell
        
        let doubt = orderedDoubts[ indexPath.row ]
        
        if doubt.anonymous == false {
            cell.nameLabel.text = doubt.person.name
        } else {
            cell.nameLabel.text = StringUtil.anonimo
        }
        
        cell.textDoubtLabel.text = doubt.text
        cell.hourLabel.text = DateUtil.hour(doubt.createdat)
        cell.countLikesLabel.text = String(doubt.likes)
        
        cell.likeButton.setImage(ImageUtil.imageLikeButton, forState: .Normal)
        cell.likeButton.tintColor = ColorUtil.orangeColor
        
        //passagem de id para url de like na dúvida
        cell.likeButton.tag = doubts[ indexPath.row ].id
        
        if doubt.like == false {
            cell.likeButton.addTarget(self, action: #selector(DoubtViewController.likeButtonPressed), forControlEvents: .TouchUpInside)
            cell.likeButton.setImage(ImageUtil.imageLikeButton, forState: .Normal)
            cell.likeButton.tintColor = UIColor.grayColor()
        } else {
            cell.likeButton.addTarget(self, action: #selector(DoubtViewController.deleteLikeButtonPressed), forControlEvents: .TouchUpInside)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        doubt = orderedDoubts[ indexPath.row ]
        
        let doubtsResponse = DoubtsResponseTabBarViewController()
        doubtsResponse.instruction = instruction
        doubtsResponse.presentation = presentation
        doubtsResponse.doubt = doubt
        
        self.navigationController?.pushViewController(doubtsResponse, animated: true)
    }
    
    func likeButtonPressed(sender: UIButton) {
        let request = Server.postResquestNotSendCookie(Server.presentationURL+"\(instruction.id)" + Server.presentaion_bar + "\(presentation.id)" + Server.doubt_bar + "\(sender.tag)" + Server.like)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print(error)
                return
            } else {
                if let httpResponse = response as? NSHTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
                    let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(fields, forURL: response!.URL!)
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response!.URL!, mainDocumentURL: nil)
                    
                    if httpResponse.statusCode == 404 {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.presentViewController(DefaultViewController.alertMessage(StringUtil.msgErrorRequest), animated: true, completion: nil)
                        })
                    } else if httpResponse.statusCode == 401 {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.presentViewController(DefaultViewController.alertMessage(StringUtil.msgNotRankYourDoubt), animated: true, completion: nil)
                        })
                    } else if httpResponse.statusCode == 200 {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.viewDidAppear(true)
                        })
                    }
                }
                print(response)
            }
        }
        task.resume()
    }
    
    func deleteLikeButtonPressed(sender: UIButton) {
        let request = Server.deleteRequest(Server.presentationURL+"\(instruction.id)" + Server.presentaion_bar + "\(presentation.id)" + Server.doubt_bar + "\(sender.tag)" + Server.like)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print(error)
                return
            } else {
                if let httpResponse = response as? NSHTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
                    let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(fields, forURL: response!.URL!)
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response!.URL!, mainDocumentURL: nil)
                    
                    if httpResponse.statusCode == 404 {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.presentViewController(DefaultViewController.alertMessage(StringUtil.msgErrorRequest), animated: true, completion: nil)
                        })
                    } else if httpResponse.statusCode == 401 {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.presentViewController(DefaultViewController.alertMessage(StringUtil.msgNotRankYourDoubt), animated: true, completion: nil)
                        })
                    } else if httpResponse.statusCode == 200 {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.viewDidAppear(true)
                        })
                    }
                }
                print(response)
            }
        }
        task.resume()
    }
    
    init() {
        super.init(nibName: StringUtil.rankingDoubtViewController, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
