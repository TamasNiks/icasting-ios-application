//
//  NewsTableViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 09-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {

        
    let _newsItemID : String = "54e6fbf172a116be7fe7f8ab"
    let news : News = News()
    var newsItems : [AnyObject] = []
    var item : String = "NIL"
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // When the view is loaded, get all the news items from the news model
//        news.get() { result in

//            self.newsItems = data as! [AnyObject]
//            self.tableView.reloadData()

  //      }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NewsItemCell", forIndexPath: indexPath) as! UITableViewCell

        var summary : String = self.newsItems[indexPath.row]["summary"] as! String
        
        cell.textLabel?.text = summary
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var str : String = self.newsItems[indexPath.row]["body"] as! String
        self.item = str
        performSegueWithIdentifier("ShowDetailNews", sender: self)
    
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        var vc : NewsDetailViewController = segue.destinationViewController as! NewsDetailViewController
        vc.news = self.item
        //println(self.item)
        
    }


}
