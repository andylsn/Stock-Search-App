//
//  DetailController.swift
//  csci hw9
//
//  Created by LiShunni on 5/3/16.
//  Copyright © 2016 LiShunni. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class DetailController: UIViewController, UITableViewDataSource {
    
    var quote: String = ""
    var rowName: [String] = ["Name", "Symbol", "Last Price", "Change", "Time and Date", "Market Cap", "Volume", "Change YTD", "High Price", "Low Price", "Opening Price"]

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var chartview: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    var islike: Bool = false
    var json: AnyObject?
    
    @IBAction func clickLike(sender: UIButton) {
        let img = UIImage(named: "Star_filled")
        
        sender.setImage(img, forState: .Normal)
        
        if islike {
            islike = false
            let img = UIImage(named: "Star_empty")
            sender.setImage(img, forState: .Normal)
            clear(self.quote)
        }
        else {
            islike = true
            let img = UIImage(named: "Star_filled")
            sender.setImage(img, forState: .Normal)
            save(self.quote)
        }
    }
    
    @IBAction func fbShare(sender: UIButton) {
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent();
        content.contentURL = NSURL(string: "http://finance.yahoo.com/q?s="+self.quote)
        
        let name = self.json!["Name"] as? String
        let lastPrice = self.json!["LastPrice"] as! Double
        
        
        content.contentTitle = "Current Stock Price of " + name! + " is " + String(format: "$%0.2f", lastPrice)
        content.contentDescription = "Stock Information of \(name!) (\(self.quote))"
        content.imageURL = NSURL(string: "http://chart.finance.yahoo.com/t?s=\(self.quote)&lang=en-US&width=400&height=300")
        
        let dlg = FBSDKShareDialog()
        dlg.shareContent = content
        dlg.mode = FBSDKShareDialogMode.FeedBrowser
        dlg.show()
        //        dlg.showFromViewController(self, withContent: content, delegate: nil)
        //        let button : FBSDKShareButton = FBSDKShareButton()
        //        button.shareContent = content
        //        button.frame = CGRectMake((UIScreen.mainScreen().bounds.width - 100) * 0.5, 50, 100, 25)
        //        self.view.addSubview(button)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = quote
        get_data_from_url("http://csci571-1278.appspot.com/?quote=" + quote)
        loadChart()
        
        if isIn(self.quote) {
            islike = true
            let img = UIImage(named: "Star_filled")
            likeButton.setImage(img, forState: .Normal)
        }
        else {
            islike = false
            let img = UIImage(named: "Star_empty")
            likeButton.setImage(img, forState: .Normal)
        }
        
        let newBackButton = UIBarButtonItem(title: "< Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DetailController.back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton;
    }
    
    func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        // ...
        // Go back to the previous ViewController
        self.navigationController!.navigationBar.hidden = true;
        self.navigationController?.popToRootViewControllerAnimated(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
//    
//    override func viewWillDisappear(animated : Bool) {
//        super.viewWillDisappear(animated)
//        
//        if (self.isMovingFromParentViewController()){
//            // Your code...
//            self.navigationController!.navigationBar.hidden = true;
//        }
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CustomCell
        
        cell.rowHead.text = rowName[indexPath.row]
        cell.rowHead.font =  UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        
        if self.json != nil {
            switch indexPath.row {
            case 0:
                let name = self.json!["Name"] as? String
                cell.rowData.text = name
                break
            case 1:
                let symbol = self.json!["Symbol"] as? String
                cell.rowData.text = symbol
                break
            case 2:
                let lastPrice = self.json!["LastPrice"] as! Double
                cell.rowData.text = String(format: "$ %0.2f", lastPrice)
                break
            case 3:
                let change = self.json!["Change"] as! Double
                let changePercent = self.json!["ChangePercent"] as! Double
                
                let changeR = Double(round(100*change)/100)
                if changeR > 0 {
                    cell.rowData.text = String(format: "%0.2f(%0.2f%%)", change, changePercent)
                    
                    let attachment:NSTextAttachment = NSTextAttachment()
                    attachment.image = UIImage(named: "Up")
                    let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
                    
                    let myString:NSMutableAttributedString = NSMutableAttributedString(string: cell.rowData.text!)
                    myString.appendAttributedString(attachmentString)
                    cell.rowData.attributedText = myString
                }
                else if changeR < 0 {
                    cell.rowData.text = String(format: "%0.2f(%0.2f%%)", change, changePercent)
                    
                    let attachment:NSTextAttachment = NSTextAttachment()
                    attachment.image = UIImage(named: "Down")
                    let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
                    
                    let myString:NSMutableAttributedString = NSMutableAttributedString(string: cell.rowData.text!)
                    myString.appendAttributedString(attachmentString)
                    cell.rowData.attributedText = myString


                }
                else if changeR == 0 {
                    cell.rowData.text = "0(0%)"
                }
                break
            case 4:
                let timestamp = self.json!["Timestamp"] as? String
                
                let dateFormatter = NSDateFormatter()
                //"Wed May 4 15:59:59 UTC-04:00 2016"
                dateFormatter.dateFormat = "EEE MMM d HH:mm:ss 'UTC-04:00' yyyy"
                dateFormatter.timeZone = NSTimeZone(name: "UTC-04:00")
                
                guard let date = dateFormatter.dateFromString(timestamp!) else {
                    assert(false, "no date from string")
                }
                
                dateFormatter.dateFormat = "MMM d yyyy HH:mm"
                dateFormatter.timeZone = NSTimeZone(name: "PST")
                cell.rowData.text = dateFormatter.stringFromDate(date)
                break
            case 5:
                let cap = self.json!["MarketCap"] as! Double
                cell.rowData.text = String(format: "%0.2f Billion", cap / pow(10,9))
                break
            case 6:
                let volume = self.json!["Volume"]  as! Int
                cell.rowData.text = "\(volume)"
                break
            case 7:
                let changeYTD = self.json!["ChangeYTD"] as! Double
                let changePercentYTD = self.json!["ChangePercentYTD"] as! Double
                
                let changeYTDR = Double(round(100*changeYTD)/100)
                if changeYTDR > 0 {
                    cell.rowData.text = String(format: "+%0.2f(%0.2f%%)", changeYTD, changePercentYTD)
                    
                    let attachment:NSTextAttachment = NSTextAttachment()
                    attachment.image = UIImage(named: "Up")
                    let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
                    
                    let myString:NSMutableAttributedString = NSMutableAttributedString(string: cell.rowData.text!)
                    myString.appendAttributedString(attachmentString)
                    cell.rowData.attributedText = myString

                }
                else if changeYTDR < 0 {
                    cell.rowData.text = String(format: "%0.2f(%0.2f%%)", changeYTD, changePercentYTD)
                    
                    let attachment:NSTextAttachment = NSTextAttachment()
                    attachment.image = UIImage(named: "Down")
                    let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
                    
                    let myString:NSMutableAttributedString = NSMutableAttributedString(string: cell.rowData.text!)
                    myString.appendAttributedString(attachmentString)
                    cell.rowData.attributedText = myString

                }
                else if changeYTDR == 0 {
                    cell.rowData.text = "0(0%)"
                }
                break
            case 8:
                let highPrice = self.json!["High"] as! Double
                cell.rowData.text = String(format: "$ %0.2f", highPrice)
                break
            case 9:
                let lowPrice = self.json!["Low"] as! Double
                cell.rowData.text = String(format: "$ %0.2f", lowPrice)
                break
            case 10:
                let openPrice = self.json!["Open"] as! Double
                cell.rowData.text = String(format: "$ %0.2f", openPrice)
                break
            default:
                break
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowName.count
    }
    
    func get_data_from_url(url:String){
        let url:NSURL = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        
        let task = session.dataTaskWithRequest(request) {(let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.extract_json(data!)
                return
            })
        }
        
        task.resume()
        
    }
    
    func extract_json(jsonData:NSData)
    {
        do {
            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String: AnyObject]
        } catch {
            json = nil
            return
        }
        
        
        do_table_refresh()
    }
    
    
    
    
    func do_table_refresh()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableview.reloadData()
            return
        })
    }
    
    func loadChart() {
        if let url = NSURL(string: "http://chart.finance.yahoo.com/t?s=" + self.quote + "&lang=en-US&width=400&height=300") {
            if let data = NSData(contentsOfURL: url) {
                chartview.image = UIImage(data: data)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toNews" {
            let news:NewsController = (segue.destinationViewController as? NewsController)!
            news.quote = self.quote
        }
        
        if segue.identifier == "toHistorical" {
            let chart: ChartController = (segue.destinationViewController as? ChartController)!
            chart.quote = self.quote
        }
    }
    
    func save(name:String)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //Data is in this case the name of the entity
        let entity = NSEntityDescription.entityForName("Data",
                                                       inManagedObjectContext: managedContext)
        let options = NSManagedObject(entity: entity!,
                                      insertIntoManagedObjectContext:managedContext)
        
        options.setValue(name, forKey: "name")
        
        
        do {
            try managedContext.save()
        } catch
        {
            print("error")
        }
        
        
    }
    
    func read() -> [String]
    {
        var name_list = [String]()
        do
        {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: "Data")
            
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest)
            
            for i in 0 ..< fetchedResults.count {
                let single_result = fetchedResults[i]
                let out = single_result.valueForKey("name") as! String
                //                print(out)
                name_list.append(out)
            }
            
            
        }
        catch
        {
            print("error")
        }
        
        return name_list
    }
    
    func clear(name: String) {
        do
        {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: "Data")
            
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest)
            
            
            for i in 0 ..< fetchedResults.count {
                let value = fetchedResults[i]
                if value.valueForKey("name") as! String == name {
                    managedContext.deleteObject(value as! NSManagedObject)
                    try managedContext.save()
                }
            }
            
        }
        catch
        {
            print("error")
        }
        
        
    }
    
    func isIn(name: String) -> Bool {
        do
        {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: "Data")
            
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest)
            
            
            for i in 0 ..< fetchedResults.count {
                let value = fetchedResults[i]
                if value.valueForKey("name") as! String == name {
                    return true
                }
            }
            return false
            
        }
        catch
        {
            print("error")
        }
        
       return false
    }
    
    func clear_data()
    {
        
        do
        {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: "Data")
            
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest)
            
            
            for i in 0 ..< fetchedResults.count {
                let value = fetchedResults[i]
                managedContext.deleteObject(value as! NSManagedObject)
                try managedContext.save()
            }
            
        }
        catch
        {
            print("error")
        }
        
    }

}
