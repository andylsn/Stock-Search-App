//
//  NewsController.swift
//  csci hw9
//
//  Created by LiShunni on 5/4/16.
//  Copyright © 2016 LiShunni. All rights reserved.
//

import UIKit

class NewsController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var quote: String = ""
    var newsArr: [[String: AnyObject]] = []
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = quote
        get_data_from_url("http://csci571-1278.appspot.com/?news=" + quote)
        
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
        let json: AnyObject?
        do {
            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String: AnyObject]
            if json != nil {
                if let d = json!["d"] as? [String: AnyObject] {
                    newsArr = d["results"] as! [[String: AnyObject]]
                }
            }
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

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("newsCell", forIndexPath: indexPath) as! NewsCell
        if let title = newsArr[indexPath.row]["Title"] as? String {
            cell.newsTitle.text = title
            cell.newsTitle.font = UIFont(name:"HelveticaNeue-Bold", size: 18.0)
        }
        if let content = newsArr[indexPath.row]["Description"] as? String {
            cell.newsContent.text = content
        }
        if let source = newsArr[indexPath.row]["Source"] as? String {
            cell.newsSource.text = source
        }
        if let date = newsArr[indexPath.row]["Date"] as? String {
            
            let dateFormatter = NSDateFormatter()
            //"Wed May 4 15:59:59 UTC-04:00 2016"
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            
            guard let newdate = dateFormatter.dateFromString(date) else {
                assert(false, "no date from string")
            }
            
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            cell.newsDate.text = dateFormatter.stringFromDate(newdate)
            
            //cell.newsDate.text = date
        }
        if let url = newsArr[indexPath.row]["Url"] as? String {
            cell.tolink = url
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArr.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? NewsCell
        let url = cell?.tolink
        UIApplication.sharedApplication().openURL(NSURL(string: url!)!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toHistorical" {
            let news:ChartController = (segue.destinationViewController as? ChartController)!
            news.quote = self.quote
        }
        
        if segue.identifier == "toDetail" {
            let chart: DetailController = (segue.destinationViewController as? DetailController)!
            chart.quote = self.quote
        }
    }
}
