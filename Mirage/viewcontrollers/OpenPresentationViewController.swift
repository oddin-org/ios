//
//  OpenPresentationViewController.swift
//  Mirage
//
//  Created by Siena Idea on 27/04/16.
//  Copyright © 2016 Siena Idea. All rights reserved.
//

import UIKit

class OpenPresentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddNewPresentationDelegate {
   
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    //inicialização de variaveis para disciplinas
    var idDisc: Int = Discipline().id
    var profileDisc: Int = Discipline().profile
    var nameDisc: String = Discipline().name
    
    //inicialização de variaveis para apresentações
    var id = Presentation().id
    var subject  = Presentation().subject
    
    var presentation = Array<Presentation>()
    var openPresentation = Array<Presentation>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(OpenPresentationViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        //verifica se é um perfil de professor para fechar apresentações
        if profileDisc == 2 {
            
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(OpenPresentationViewController.longPress(_:)))
            self.view.addGestureRecognizer(longPressRecognizer)
            
        }
        
        refreshTableView()
    }
    
    override func viewDidAppear(animated: Bool) {
        refreshTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshTableView()
    }
    
    func refreshTableView() {
        
        if tableView == nil {
            return
        } else {
            tableView.delegate = self
            tableView.dataSource = self
            let nib = UINib(nibName: "PresentationCell", bundle: nil)
            tableView.registerNib(nib, forCellReuseIdentifier: "cell")
            view.addSubview(tableView)
            
            getPresentation()
            tableView.reloadData()
        }
    }
    
    //chama displayAlert para fechar apresentação
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = longPressGestureRecognizer.locationInView(self.tableView)
            
            if let indexPah = tableView.indexPathForRowAtPoint(touchPoint) {
                
                let id  = openPresentation[ indexPah.row ].id
                let subject  = openPresentation[ indexPah.row ].subject
                
                displayMyAlertMessage("Fechar apresentação?", subject: subject, id: id)
            }
        }
    }
    
    // pull to refresh
    func refresh() {
        getPresentation()
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    func getPresentation() {
        let request: NSMutableURLRequest = NSMutableURLRequest()
        let urlPath = Server.presentationURL+"\(idDisc)" + "/presentation"
        let url = NSURL(string: urlPath)!
        
        let cookieHeaderField = ["Set-Cookie": "key=value"]
        
        let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(cookieHeaderField, forURL: url)
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: url, mainDocumentURL: nil)
        
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        print(cookies)
        
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            if (error != nil) {
                print("Download Error: \(error!.localizedDescription)")
            } else {
                var studentJSONParseError: NSError?
                
                let presentationJSONData = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                if (studentJSONParseError != nil) {
                    
                    print("JSON Parsing Error: \(studentJSONParseError!.localizedDescription)")
                    
                } else {
                    
                    let info : NSArray =  presentationJSONData.valueForKey("presentations") as! NSArray
                    let person : NSArray = info.valueForKey("person") as! NSArray
                    
                    for i in 0 ..< info.count {
                        if self.presentation.count == info.count {
                            return
                        } else {
                            
                            let presentations = Presentation()
                            let persons = Person()
                            
                            for j in 0 ..< person.count {
                                persons.name = person[j].valueForKey("name") as! String
                            }
                            
                            presentations.id = info[i].valueForKey("id") as! Int
                            presentations.person = persons
                            presentations.createdat = info[i].valueForKey("createdat") as! String
                            presentations.status = info[i].valueForKey("status") as! Int
                            presentations.subject = info[i].valueForKey("subject") as! String
                            
                            self.presentation.insert(presentations, atIndex: i)
                        }
                    }
                    print(presentationJSONData)
                }
            }
        })
        
        task.resume()
        
        openPresentation.removeAll()
        
        var auxPresent = Array<Presentation>()
        
        for i in 0 ..< presentation.count {
            var j = 0
            
            if presentation[i].status == 0 {
                auxPresent.insert(presentation[i], atIndex: j)
                j += 1
            }
        }
        
        openPresentation = auxPresent.reverse()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return openPresentation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! PresentationTableViewCell
        
        let present = openPresentation[ indexPath.row ]
        
        cell.subjectLabel.textColor = ColorUtil.colorPrimaryText
        cell.dateLabel.textColor = ColorUtil.colorSecondaryText
        
        cell.subjectLabel.text = present.subject
        cell.dateLabel.text = present.createdat
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        id = openPresentation[ indexPath.row ].id
        subject = openPresentation[ indexPath.row ].subject
        
        let doubtTabBar  = DoubtTabBarViewController()
        
        doubtTabBar.idDisc = idDisc
        doubtTabBar.profileDisc = profileDisc
        doubtTabBar.nameDisc = nameDisc
        
        doubtTabBar.idPresent = id
        doubtTabBar.subjectPresent = subject
        
        self.navigationController?.pushViewController(doubtTabBar, animated: true)
    }
    
    
    init() {
        super.init(nibName: "OpenPresentationViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    //exibe mensagens de alerta
    func displayMyAlertMessage(userMessage: String, subject: String, id: Int) {
        
        let myAlert = UIAlertController(title: subject, message: userMessage, preferredStyle:
            UIAlertControllerStyle.Alert)
        
        let okAction: UIAlertAction = UIAlertAction(title: "CONFIRMAR", style: .Destructive) { action -> Void in
            
            let request: NSMutableURLRequest = NSMutableURLRequest()
            let urlPath = Server.presentationURL+"\(self.idDisc)" + "/presentation/" + "\(id)" + "/close"
            
            request.URL = NSURL(string: urlPath)
            request.HTTPMethod = "POST"
            request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in
                
                if error != nil {
                    print("error=\(error)")
                    return
                } else {
                    if let httpResponse = response as? NSHTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
                        let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(fields, forURL: response!.URL!)
                        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response!.URL!, mainDocumentURL: nil)
                        
                        if httpResponse.statusCode == 404 {
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                
                            })
                        }
                        
                        if httpResponse.statusCode == 401 {
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                
                            })
                        }
                        
                        
                        if httpResponse.statusCode == 200 {
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                self.navigationController?.popViewControllerAnimated(true)
                                
                            })
                        }
                    }
                    print(response)
                }
            }
            task.resume()
        }
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "CANCELAR", style: .Cancel) { action -> Void in
            
            print("cancel")
        }
        
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }

}