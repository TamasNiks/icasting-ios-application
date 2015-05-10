//
//  NewsDetailViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 10-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class TEMPNewsDetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    //@IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var bodyLabel: UILabel!

    var item: NSDictionary?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.scrollView.contentSize = CGSize(width: 500, height: 1000)
        
        self.bodyLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.bodyLabel.numberOfLines = 0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var imageID : String = self.item?.objectForKey(NewsKey.ImageID) as! String
        var news: News = News()

        
        news.image(imageID, size: ImageSize.Thumbnail) { result in
            
            var im: UIImage = UIImage(data: result.success as! NSData)!
            self.imageView.image = im
        }

        
        self.bodyLabel.text = self.item?.objectForKey(NewsKey.Body) as? String
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
