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

    func handleRefresh(sender: AnyObject) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
        dispatch_after(popTime, dispatch_get_main_queue(), {
            self.handleRequest()
        })
    }
    
    func handleRequest() {
        news.all() { failure in
            self.refreshControl!.endRefreshing()
            if let failure: ICErrorInfo = failure {
                println(failure.description)
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: ("handleRefresh:"), forControlEvents: UIControlEvents.ValueChanged)

        // When the view is loaded, get all the news items from the news model
        refreshControl?.beginRefreshing()
        handleRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
            cell.indentationLevel = 0
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let item = self.item {
            var vc: NewsDetailViewController = segue.destinationViewController as! NewsDetailViewController
            vc.item = item
        }
    }


}
