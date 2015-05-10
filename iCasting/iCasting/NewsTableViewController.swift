//
//  NewsTableViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 09-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.bounds = CGRectMake(0, 0, 55, 55)
    }
}

class NewsTableViewController: UITableViewController {

    let news : News = News()
    var item : NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // When the view is loaded, get all the news items from the news model
        news.all() { failure in
            
            if let failure: ICErrorInfo = failure {
                
                println(failure.description)
                
            } else {
                
                self.tableView.reloadData()
                
            }
        }
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
        return news.newsItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NewsItemCell", forIndexPath: indexPath) as! NewsCell
        
        //var summary:String = self.newsItems[indexPath.row]["summary"] as! String
        
        let item: AnyObject = news.newsItems[indexPath.row]
        
        var title: String? = item[NewsKey.Title] as? String
        var image: String = item[NewsKey.ImageID] as? String ?? ""
        var published: String? =  (item[NewsKey.Published] as? String ?? "").ICdateToString(ICDateFormat.News) //?? "no valid date"
        
        
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = published
        
        news.image(image, size: ImageSize.Thumbnail) { result in
            
            if result.success is NSDictionary {
            } else {
                cell.imageView?.image = UIImage(data: result.success as! NSData)
            }
            
            cell.setNeedsLayout()
            
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.item = news.newsItems[indexPath.row] as? NSDictionary
        performSegueWithIdentifier("ShowDetail2News", sender: self)
    
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
        
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
        
        
        if let item = self.item {
            
//            if segue.destinationViewController is NewsDetailViewController {
//                var vc: NewsDetailViewController = segue.destinationViewController as! NewsDetailViewController
//                vc.item = item
//            } else {
                var vc: NewsDetailViewController = segue.destinationViewController as! NewsDetailViewController
                vc.item = item
//            }

        }
    
        
        //println(self.item)
        
    }


}
