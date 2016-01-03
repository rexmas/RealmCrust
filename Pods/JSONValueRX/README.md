[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/JSONValueRX.svg)](https://img.shields.io/cocoapods/v/JSONValueRX.svg)
[![Build Status](https://travis-ci.org/rexmas/JSONValue.svg)](https://travis-ci.org/rexmas/JSONValue)

# JSONValue
Simple JSON representation supporting subscripting and pattern matching.
JSONValue uses an algebraic datatype representation of JSON for type safety and pattern matching.
```swift
enum JSONValue : CustomStringConvertible {
    case JSONArray([JSONValue])
    case JSONObject([String : JSONValue])
    case JSONNumber(Double)
    case JSONString(String)
    case JSONBool(Bool)
    case JSONNull()
}
```
#Requirements
iOS 8.0+
Swift 2.1+

#Installation
### CocoaPods
```
platform :ios, '8.0'
use_frameworks!

pod 'JSONValueRX'
```

#Subscripting
Supports `.` indexing
```swift
let dict = [ "blerp" : [ "z" : "zerp" ]]
var jsonVal = try! JSONValue(object: dict)

print(jsonVal["blerp.z"])
// Optional(JSONString(zerp))

jsonVal["blerp.w"] = try! JSONValue(object: "werp")
print(jsonVal["blerp.w"])
// Optional(JSONString(werp))
```
Supports `.` in keys
```swift
let dict = [ "blerp.z" : "zerp" ]
var jsonVal = try! JSONValue(object: dict)

print(jsonVal["blerp.z"])
// Optional(JSONString(zerp))

jsonVal[["blerp.w"]] = try! JSONValue(object: "werp")
print(jsonVal["blerp.w"])
// Optional(JSONString(werp))
```

#Equatable
```swift
print(JSONValue.JSONNumber(1.0) == JSONValue.JSONNumber(1.0))
// true
```

#Hashable
`extension JSONValue : Hashable`

Inverted key/value pairs do not collide.
```swift
let hashable1 = try! JSONValue(object: ["blah" : "zerp"])
let hashable2 = try! JSONValue(object: ["zerp" : "blah"])

print(hashable1.hashValue)
// -8516032725034193623
print(hashable2.hashValue)
// 2895177120076124296
```
#Encoding/Decoding from String, NSData
```swift
public func encode() throws -> NSData
public static func decode(data: NSData) throws -> JSONValue
public static func decode(string: String) throws -> JSONValue
```

#Custom Encoding/Decoding
```swift
public protocol JSONDecodable {
    typealias ConversionType = Self
    static func fromJSON(x : JSONValue) -> ConversionType?
}

public protocol JSONEncodable {
    typealias ConversionType
    static func toJSON(x : ConversionType) -> JSONValue
}

public protocol JSONable : JSONDecodable, JSONEncodable { }
```
The following support `JSONable` for out-of-the-box Encoding/Decoding.
```swift
NSNull
Double
Bool
Int
NSDate
Array
String
Dictionary
```
`NSDate` uses built in `ISO` encoding/decoding to/from `.JSONString`

# Contributing

We love pull requests and solving bugs.

- Open an issue if you run into any problems.
- Fork the project and submit a pull request to contribute.

#License
The MIT License (MIT)

Copyright (c) 2015 Rex

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
