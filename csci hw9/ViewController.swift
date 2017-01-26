//
//  ViewController.swift
//  csci hw9
//
//  Created by LiShunni on 4/19/16.
//  Copyright © 2016 LiShunni. All rights reserved.
//

import UIKit
import CCAutocomplete
import CoreData

class ViewController: UIViewController, UITableViewDelegate{

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var autoRefresh: UISwitch!
    
    var isFirstLoad: Bool = true
    var name_list = [String]()
    var json_list = [AnyObject]()
    var quote: String = ""
    var myTimer: NSTimer?
    
    @IBAction func getQuote(sender: AnyObject) {
        if searchField.text == "" {
            let alert = UIAlertController(title: "Please Enter a Stock Name or Symbol.", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            return
        }
        
        if !validateQuote() {
            let alert = UIAlertController(title: "Invalid symbol.", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            return

        }
        
        self.quote = searchField.text!
        performSegueWithIdentifier("toDetail", sender: self)
    }
    
    func validateQuote() -> Bool {
        var isValid = false
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://csci571-1278.appspot.com/?quote=" + searchField.text!)!)
        let session = NSURLSession.sharedSession()
        let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                
                if let status = json["Status"] as? String{
                    if status == "SUCCESS" {
                        isValid = true
                    }
                    else {
                        isValid = false
                    }
                }
                else{
                    isValid = false
                }
                
                dispatch_semaphore_signal(semaphore);
                
            }catch {
                print("Error with Json: \(error)")
            }
            
        })
        
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return isValid
    }
    
    @IBAction func refresh(sender: UIButton) {
        load_table()
    }
    
    @IBAction func switchChanged(sender: UISwitch) {
        if autoRefresh.on {
            myTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ViewController.sayHello), userInfo: nil, repeats: true)
        }
        else {
            myTimer!.invalidate()
            myTimer = nil
//            print("stop")
        }
    }
    
    func sayHello(){
//        print("refresh")
        load_table()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController!.navigationBar.hidden = true;
        
//        //save the data
//        clear_data()
//        save("GOOGL")
//        save("TSLA")
//        save("AAPL")
        
        load_table()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        load_table()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.isFirstLoad {
            self.isFirstLoad = false
            Autocomplete.setupAutocompleteForViewcontroller(self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detail:DetailController = (segue.destinationViewController as? DetailController)!
        
        if segue.identifier == "toDetail" {
            self.navigationController!.navigationBar.hidden = false;
            
            detail.quote = self.quote
        }
    }
    
    func load_table() {
        name_list = read()
        json_list.removeAll()
//        print(name_list)
        
        for each in name_list {
            let request = NSMutableURLRequest(URL: NSURL(string: "http://csci571-1278.appspot.com/?quote=" + each)!)
            let session = NSURLSession.sharedSession()
            let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    self.json_list.append(json)
                    dispatch_semaphore_signal(semaphore);
                    
                }catch {
                    print("Error with Json: \(error)")
                }
                
            })
            
            task.resume()
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

        }
        
        self.tableview.reloadData()
//        print(name_list)
//        print(json_list)
    }
    
//    func get_data_from_url(url:String){
//        let url:NSURL = NSURL(string: url)!
//        let session = NSURLSession.sharedSession()
//        
//        let request = NSMutableURLRequest(URL: url)
//        request.HTTPMethod = "GET"
//        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
//        
//        
//        let task = session.dataTaskWithRequest(request) {(let data, let response, let error) in
//            
//            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
//                print("error")
//                return
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), {
//                self.extract_json(data!)
//                return
//            })
//        }
//        
//        task.resume()
//    }
//    
//    func extract_json(jsonData:NSData)
//    {
//        let json: AnyObject?
//        do {
//            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String: AnyObject]
//          
//        } catch {
//            json = nil
//            return
//        }
//        
//        do_table_refresh()
//    }
//    
//    func do_table_refresh()
//    {
//        dispatch_async(dispatch_get_main_queue(), {
//            self.tableview.reloadData()
//            return
//        })
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("infoCell", forIndexPath: indexPath) as! InfoCell
        
        if !json_list.isEmpty {
            cell.symbol.text = json_list[indexPath.row]["Symbol"] as? String
            let lastPrice = json_list[indexPath.row]["LastPrice"] as! Double
            cell.price.text = String(format: "$ %0.2f", lastPrice)
            cell.company.text = json_list[indexPath.row]["Name"] as? String
            let cap = json_list[indexPath.row]["MarketCap"] as! Double
            cell.cap.text = "Market Cap: " + String(format: "%0.2f Billion", cap / pow(10,9))

            let change = json_list[indexPath.row]["Change"] as! Double
            let changePercent = json_list[indexPath.row]["ChangePercent"] as! Double
            
            let changeR = Double(round(100*change)/100)
            if changeR > 0 {
                cell.change.text = String(format: "+%0.2f(%0.2f%%)", change, changePercent)
                cell.change.backgroundColor = UIColor.greenColor()

            }
            else if changeR < 0 {
                cell.change.text = String(format: "%0.2f(%0.2f%%)", change, changePercent)
                cell.change.backgroundColor = UIColor.redColor()
                
            }
            else if changeR == 0 {
                cell.change.text = "0(0%)"
            }

            
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return name_list.count
    }
    
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        let del = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
//            print("more button tapped")
//        }
//        del.backgroundColor = UIColor.redColor()
//        
//        return [del]
//
//    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
        if editingStyle == .Delete {
            // Delete the row from the data source
            clear(name_list[indexPath.row])
            name_list.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.quote = name_list[indexPath.row]
        performSegueWithIdentifier("toDetail", sender: self)
    }
}

extension ViewController: AutocompleteDelegate {
    func autoCompleteTextField() -> UITextField {
        return self.searchField
    }
    
    func autoCompleteThreshold(textField: UITextField) -> Int {
        return 2
    }
    
    func autoCompleteItemsForSearchTerm(term: String) -> [AutocompletableOption] {
        
        var itemArr = [String]()
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://csci571-1278.appspot.com/?symbol=" + term)!)
        let session = NSURLSession.sharedSession()
        let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                
                for i in 0..<json.count {
                    var str: String
                    if let symbol = json[i]["Symbol"] as? String {
                        if let name = json[i]["Name"] as? String {
                            if let exchange = json[i]["Exchange"] as? String {
                                str = symbol + "-" + name + "-" + exchange
                                itemArr.append(str)
                            }
                        }
                    }
                }
                dispatch_semaphore_signal(semaphore);
                
            }catch {
                print("Error with Json: \(error)")
            }
            
        })
        
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        let symbolArr: [AutocompletableOption] = itemArr.map { (item) -> AutocompleteCellData in
            return AutocompleteCellData(text: item, image: nil)
            }.map({ $0 as AutocompletableOption })
        
        return symbolArr
    }
    
    func autoCompleteHeight() -> CGFloat {
        return CGRectGetHeight(self.view.frame) / 3.0
    }
    
    func didSelectItem(item: AutocompletableOption) {
        let sepSelected = (self.searchField.text!).characters.split{$0 == "-"}.map(String.init)
        self.searchField.text = sepSelected[0]

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