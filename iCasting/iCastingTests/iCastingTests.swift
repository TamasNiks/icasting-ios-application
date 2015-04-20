//
//  iCastingTests.swift
//  iCastingTests
//
//  Created by T. van Steenoven on 03-04-15.
//  Copyright (c) 2015 T. van Steenoven. All rights reserved.
//

import UIKit
import XCTest

class iCastingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testValidator() {
        
        var c : Credentials = Credentials(email: "", password: "")
        var v : Validator = Validator(credentials: c)
        
        if let arr = v.check() {
            XCTAssertEqual(arr.count, 3, "Contains 3 errors, which is good")
        } else {
            XCTAssert(false, "Contains no errors, while it should")
        }
    }
    
    
    func testRequest() {
        
        var params : [String:String] = ["access_token":"551d58a226042f74fb745533$aav7DtkBMnG/vBDzb5RHfIzuZY++39r1vCXrj4jxVHA="]
        var type : RequestProtocol = RequestFactory.request(Method.post)
        var request = type.create(APIAuth.Logout, content: (insert: nil, params: params))
        
        var data : NSData = request.HTTPBody!
        
        var str : NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        println("testRequest")
        println(str)
    }
    
    
    func testRequestHeaderFields() {
        
        var params : [String:String] = ["access_token":"placeholder_token"]
        
        var type : RequestProtocol = RequestFactory.request(Method.post)
        var request = type.create(APIAuth.Logout, content: (insert: nil, params: params))

        var values = request.allHTTPHeaderFields!
        println("AllHTTPHeaderFields:")
        println(values)
        
//        var type : RequestHeaderProtocol = (RequestFactory.requestType(Method.post) as? RequestHeaderProtocol)!
//        var request = type.request(
//            APIAuth.Logout,
//            content: (insert: nil, params: params),
//            withHeaders: ["":"Authorization"])
        

//        for (key, val) in values {
//            
//            println("headerfield:", key as! String, val as! String)
//            
//        }
        
//        var v:String = ""
//        if let val = value {
//            v = val
//        } else {
//            v = "nil"
//        }
        XCTAssert(true, "")
        //XCTAssertEqual("lala", "lala", "Header field equals text passed")
        
    }
    
    func testSerializers() {
        
//        var p : paramsType = ["email":"tim.van.steenoven@icasting.com", "password":"test"]
//        var s : SerializerCommand = SerializeParametersCommand(params: p)!
//        var d : NSData = s.execute()
//        var final  = NSString(data: d, encoding: NSUTF8StringEncoding) as! String
//        println(final)
//        
//        XCTAssertEqual(
//            final,
//            "email=tim.van.steenoven@icasting.com&password=test",
//            "parameters in body request successfull formatted")
    }
    
    
    func testURLBuilder() {
        
        let url: NSURL = URLSimpleFactory.createURL(APINews.newsItems, insert: nil, params: nil)
        XCTAssert(url.absoluteString == "https://api-demo.icasting.net/api/v1/newsItems", "URL create successful")
        
        let url2: NSURL = URLSimpleFactory.createURL(APINews.newsItemWithID, insert: ["2323123132313133"], params: nil)
        XCTAssert(url2.absoluteString == "https://api-demo.icasting.net/api/v1/newsItem/2323123132313133", "URL create successful")
        
        let url3: NSURL = URLSimpleFactory.createURL(APINews.testItemIDresourceIDlala, insert: ["1","2"], params: nil)
        XCTAssert(url3.absoluteString == "https://api-demo.icasting.net/api/v1/testItem/1/resource/2/lala", "URL create successful")
        
        let url4: NSURL = URLSimpleFactory.createURL(APIMedia.imageWithIDSize, insert: ["2323123132313133", "200x200"], params: nil)
        XCTAssert(url4.absoluteString == "https://media-demo.icasting.net/site/images/2323123132313133/200x200", "Media url created successful")
        
        let urlWithParams: NSURL = URLSimpleFactory.createURL(APIMedia.imageWithIDSize, insert: ["2323123132313133", "200x200"],
            params: ["key":"val", "key2":"val2"])
        
        XCTAssertEqual(urlWithParams.absoluteString!,
            "https://media-demo.icasting.net/site/images/2323123132313133/200x200?key=val&key2=val2",
            "Media url created successful")
    }
    
    func testExample() {
        
        let sNews : String = "{\"_id\":\"54e6fbf172a116be7fe7f8ab\",\"body\":\"Dit is de body tekst\",\"subTitle\":\"Gastvrouw/gastheer zijn is een vak. Jij bent er om te zorgen dat een event of bijeenkomst zorgeloos verloopt.\",\"title\":\"De vijf do's en don’ts als host & hostess\",\"image\":\"551176590b41dda06c23951b\",\"thumbnail\":\"551176590b41dda06c23951b\",\"locales\":[],\"authors\":[\"541fda5b0f1d550000127858\"],\"highlighted\":false,\"published\":\"2015-02-20T00:00:00.000Z\",\"id\":\"54e6fbf172a116be7fe7f8ab\"}"
        
        let sSimple = "[ {\"name\": \"John\", \"age\": 21}, {\"name\": \"Bob\", \"age\": 35} ]"

        var name = "initial"
        
        // Make a data object, because the url request will return a data object
        if let data = sSimple.dataUsingEncoding(NSUTF8StringEncoding) {
            var array: AnyObject = JSONParser.Parse(data)
            name = array[0]["name"] as! String
        }
        
        var id = "initial"
        // Make a data object, because the url request will return a data object
//        if let data = sNews.dataUsingEncoding(NSUTF8StringEncoding) {
//            var dictionary: AnyObject = JSONParser.JSONParse(data)
//            id = dictionary["id"] as String
//        }

        var dictionary: AnyObject = JSONParser.mockJSONParse(sNews)!
        id = dictionary["id"] as! String
        
        println(name)
        XCTAssert(name == "John", "Passes test")
        println(id)
        XCTAssert(id == "54e6fbf172a116be7fe7f8ab", "Passes test")
    }
    
    func testJSON() {
        
        let string = "[ {\"name\": \"John\", \"age\": 21}, {\"name\": \"Bob\", \"age\": 35} ]"
        
        func JSONParseArray(jsonString: String) -> [AnyObject] {
            if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
                if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)  as? [AnyObject] {
                    return array
                }
            }
            return [AnyObject]()
        }
        
        for elem: AnyObject in JSONParseArray(string) {
            let name = elem["name"] as! String
            let age = elem["age"] as! Int
            println("Name: \(name), Age: \(age)")
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
