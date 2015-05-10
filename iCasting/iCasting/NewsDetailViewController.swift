//
//  NewsDetail2ViewController.swift
//  iCasting
//
//  Created by T. van Steenoven on 20-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    var item: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var news: News = News()
        var body: String = (self.item?.objectForKey(NewsKey.Body) as? String)!

        var html: String = "<html>"
        html += "<head>"
        html += "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
        html += "<style> body { font-family:Arial; } </style>"
        html += "</head>"
        html += "<body>"
        html += body
        html += "</body>"
        html += "</html>"
        webView.loadHTMLString(html, baseURL: nil)
        webView.delegate = self
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        let contentSize: CGSize = self.webView.scrollView.contentSize
        let viewSize: CGSize = self.view.bounds.size
        
        let rw: CGFloat = viewSize.width / contentSize.width;
        
        self.webView.scrollView.minimumZoomScale = rw;
        self.webView.scrollView.maximumZoomScale = rw;
        self.webView.scrollView.zoomScale = rw;
        
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

}
