// Playground - noun: a place where people can play

import Cocoa


struct API {
    
    static let endpoints = (
        
        Authorization : "/login/facebook",
        test : (url: "lala"),
        Authorization : "/login/facebook",
        test : (url: "lala"),
        Authorization : "/login/facebook",
        test : (url: "lala"),
        Authorization : "/login/facebook",
        test : (url: "lala"),
        Authorization : "/login/facebook",
        test : (url: "lala")
        
    )
    
    
    static let endpoints2 = ["Authorization" : ["get": ["login":"/login/facebook" ] ] ]
    
}


API.endpoints2["Authorization"]






/* Closures -> practiccaly identical to blocks */

// A block whith arguments and a return type
var closure1 = { (num: Int) -> Int in
    
    return num * 5
}

var closure2:Int -> Int = {
    
    return $0
}


var result1 : Int = closure1(5)
var result2 : Int = closure2(25)

/* Optional properties and unwrapping */

let someVal:Int? = nil

if let val = someVal {
    
    val
    
}



extension Int {
    
    var doubled: Int {
        
        get { return self * 2 }
    }
}

4.doubled


var sortarray = [1,3,5,2,6]

sort(&sortarray)

sortarray

var numbers = [2,66,33,22,1]

var numbersSorted = sorted(numbers, { (n1:Int, n2:Int) -> Bool in
    
    return n1 > n2

})

var closure = { (num:Int) -> Int in
    
    return num + 5
}

closure(5)

var terseClosure = { $0 + 5 }

terseClosure(50)



/* DELEGATE */

protocol NotifyDelegate {
    
    func handleMessage()
    
}



class RadioStation {
    
    var delegate: NotifyDelegate?
    
    init() {
        
    }
    
    func newStationDetected() {
        delegate?.handleMessage()
    }
    
}

class Listener: NotifyDelegate {
    func handleMessage() {
        println("Message sended")
    }
}


let station = RadioStation()
station.newStationDetected()

let listener = Listener()
station.delegate = listener
station.newStationDetected()





var str = "Hello, playground"

countElements(str)

if let fileURL = NSBundle.mainBundle().URLForResource("SomeFile", withExtension: "txt") {
        
        let loadedDataFromURL = NSData(contentsOfURL: fileURL)
        
}


class SerializeObject: NSObject, NSCoding {
    
    var name : String?
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name!, forKey: "name")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey("name") as? String
    }
    
    override init() {
        self.name = "MyObject"
    }

}



let anObject = SerializeObject()
anObject.name = "Tim"

let objectConvertedToDate = NSKeyedArchiver.archivedDataWithRootObject(anObject)
