//
//  ChartController.swift
//  csci hw9
//
//  Created by LiShunni on 5/5/16.
//  Copyright © 2016 LiShunni. All rights reserved.
//

import UIKit

class ChartController: UIViewController {

    var quote: String = ""
    @IBOutlet weak var chartview: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = quote
        let url = NSURL(string: "http://historicalchart.appspot.com/?v=" + quote)
        let request = NSURLRequest(URL: url!)
        chartview.loadRequest(request)
        
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
//        performSegueWithIdentifier("to", sender: <#T##AnyObject?#>)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toNews" {
            let news:NewsController = (segue.destinationViewController as? NewsController)!
            news.quote = self.quote
        }
        
        if segue.identifier == "toDetail" {
            let chart: DetailController = (segue.destinationViewController as? DetailController)!
            chart.quote = self.quote
        }
    }
}
