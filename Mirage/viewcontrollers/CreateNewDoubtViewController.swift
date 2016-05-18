//
//  CreateNewDoubtViewController.swift
//  Mirage
//
//  Created by Siena Idea on 12/05/16.
//  Copyright © 2016 Siena Idea. All rights reserved.
//

import UIKit

protocol AddNewDoubtDelegate {
    
}

class CreateNewDoubtViewController: UIViewController {

    @IBOutlet weak var doubtTextField: UITextField!
    @IBOutlet weak var anonymousButton: UIButton!
    
    var isChecked = Bool()
    var idDisc = Discipline().id
    var idPresent = Presentation().id
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Nova Dúvida"

        let saveDoubtButton = UIBarButtonItem(image: UIImage(named: "send-black.png"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CreateNewDoubtViewController.saveNewDoubt))
        
        self.navigationItem.setRightBarButtonItem(saveDoubtButton, animated: true)
        
        let uncheckedImage = UIImage(named: "checkbox-blank-outline-48")! as UIImage
        
        self.anonymousButton.setImage(uncheckedImage, forState: .Normal)
        
    }
    
    
    func saveNewDoubt() {
        
        // Compose a query string
        let text = doubtTextField.text
        let anonymous = isChecked.boolValue
        
        
        if (text!.isEmpty) {
            
            displayMyAlertMessage("Campo obrigatório")
            return
        }
        
        let JSONObject: [String : AnyObject] = [
            "text" : text!,
            "anonymous": anonymous
        ]
        
        if NSJSONSerialization.isValidJSONObject(JSONObject) {
            let request: NSMutableURLRequest = NSMutableURLRequest()
            let url = Server.presentationURL+"\(idDisc)" + "/presentation/" + "\(idPresent)" + "/doubt"
            
            let _: NSError?
            
            request.URL = NSURL(string: url)
            request.HTTPMethod = "POST"
            request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(JSONObject, options:  NSJSONWritingOptions(rawValue:0))
            
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
                                self.displayMyAlertMessage("Erro 404")
                                
                            })
                        }
                        
                        if httpResponse.statusCode == 401 {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.displayMyAlertMessage("Erro 401")
                                
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

    }

    @IBAction func anonymousButtonPressed() {
        
        // Images
        let checkedImage = UIImage(named: "checkbox-marked-black")! as UIImage
        let uncheckedImage = UIImage(named: "checkbox-blank-outline-48")! as UIImage
        
        if isChecked == true {
            isChecked = false
        } else {
            isChecked = true
        }
        
        if isChecked == true {
            self.anonymousButton.setImage(checkedImage, forState: .Normal)
        } else {
            self.anonymousButton.setImage(uncheckedImage, forState: .Normal)
        }
    }
    
    
    var delegate:AddNewDoubtDelegate?
    init(delegate:AddNewDoubtDelegate) {
        self.delegate = delegate
        super.init(nibName: "CreateNewDoubtViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func displayMyAlertMessage(userMessage: String) {
        
        let myAlert = UIAlertController(title: "Mensagem", message: userMessage, preferredStyle:
            UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //nameTextField.resignFirstResponder()
        
        
    }

}