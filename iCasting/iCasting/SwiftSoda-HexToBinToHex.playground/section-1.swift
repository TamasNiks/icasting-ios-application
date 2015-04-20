import Foundation

var swiftSoda = "535749465420534f4441"
println("Original HexString: \(swiftSoda): ")


var oddArray = [String]()
var evenArray = [String]()
var flipper = false

for character in swiftSoda {
 flipper = !flipper
 let myString = "" + character
 if flipper {
     oddArray.append(myString)
 }   else {
     evenArray.append(myString)
 }
}

var uniPrefix: String = "\\u00"
var ioString: String = ""
for (index, value) in enumerate(oddArray) {
 let evenString: String = evenArray[index]
 ioString += (uniPrefix + value as String + evenString)
}

var inputOutput = ioString.mutableCopy() as NSMutableString!
println("\nUnicode Hex: \(inputOutput)")
CFStringTransform(inputOutput as CFMutableStringRef, nil, "Hex", 1)
println("\nThis spells: \(inputOutput)")

var unicodeString: String = inputOutput as NSString
var byteArray = [Byte]()
for scalar in unicodeString.unicodeScalars {
 let myValue: Byte = Byte(scalar.value)
 byteArray.append(myValue)
}

var byteData:NSData = NSData(bytes: byteArray,length: byteArray.count)

println("\nAfter we convert it to bytes, the Computer sees it right:\n \(byteData.description)")

println("\nHere we convert it back into its original form")
var hexBits = "" as String
for value in byteArray {
 hexBits += NSString(format:"%2X", value) as String
}

//replace spaces with zeros
let hexBytes = hexBits.stringByReplacingOccurrencesOfString("\u0020", withString: "0", options: NSStringCompareOptions.CaseInsensitiveSearch)

println(hexBytes)
println("\nThank you, \(inputOutput)")
