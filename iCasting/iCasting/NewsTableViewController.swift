//
//  NewsTableViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 09-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {

    let news : News = News()
    var selectedItem : NewsItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl?.addTarget(self, action: ("handleRequest"), forControlEvents: UIControlEvents.ValueChanged)

        firstLoadRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func firstLoadRequest() {
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        startAnimatingLoaderTitleView()
        handleRequest()
    }
    
    func endLoadRequest() {
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        stopAnimatingLoaderTitleView()
        refreshControl?.endRefreshing()
    }
    
    
    func handleRequest() {
        
        news.get() { failure in
            
            self.endLoadRequest()
            
            if let failure: ICErrorInfo = failure {
                println(failure.description)
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.newsItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NewsItemCell", forIndexPath: indexPath) as! NewsOverviewCell
        
        //var summary:String = self.newsItems[indexPath.row]["summary"] as! String
        
        let item: NewsItem = news.newsItems[indexPath.row]
        
        let newstitle: String    = item.title
        let image: String        = item.imageID
        let published: String?   = item.published.ICdateToString(ICDateFormat.News) //?? "no valid date"
        
        cell.textLabel?.text = newstitle
        cell.detailTextLabel?.text = published
        cell.indentationLevel = 0
        
        // If the image has been set, the tag will change to 1
        if cell.imageView?.tag == 0 {
            cell.imageView?.image = Placeholder(frame: CGRectMake(0, 0, 100, 100)).image
            news.image(image, size: ImageSize.Thumbnail) { result in
                if let success: AnyObject = result.success {
                    cell._image = UIImage(data: success as! NSData)
                }
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedItem = news.newsItems[indexPath.row]
        performSegueWithIdentifier(SegueIdentifier.NewsDetail, sender: self)
    
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
        if let item = selectedItem {
            var vc: NewsDetailViewController = segue.destinationViewController as! NewsDetailViewController
            vc.item = item
        }
    }


}
