[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/RealmCrust.svg)](https://img.shields.io/cocoapods/v/RealmCrust.svg)
[![Build Status](https://travis-ci.org/rexmas/RealmCrust.svg)](https://travis-ci.org/rexmas/RealmCrust)

# RealmCrust
Simple [Crust](https://github.com/rexmas/Crust) Extension for Mapping Realm Objects From JSON. Use to easily map to/from JSON/Realm Objects.

#Requirements
iOS 8.0+
Swift 2.1+

#Installation

### Pods
```
platform :ios, '8.0'
use_frameworks!

pod 'Crust'
pod 'RealmCrust'
```
NOTE: RealmCrust includes Realm as a dependency but does NOT include Crust as a dependency. This is to allow the use of multiple modules that rely on Crust without dependency conflicts.

####Additional Step
Copy the following code into your project source to use RealmCrust with Crust.

```Swift
/// Instructions:
/// 1. `import Crust` and `import RealmCrust` dependencies.
/// 2. Include this section of code in your app/lib.
/// This will allow our `RealmMapping` and `RealmAdaptor` to be used with Crust.

public protocol RealmMapping {
    init(adaptor: RealmAdaptor)
}
public extension RealmAdaptor : Adaptor { }

public func <- <T: Mappable, U: Mapping, C: MappingContext where U.MappedObject == T>(field: List<T>, map:(key: KeyExtensions<U>, context: C)) -> C {

    // Realm specifies that List "must be declared with 'let'". Seems to actually work either way in practice, but for safety
    // we're going to include a List mapper that accepts fields with a 'let' declaration and forward to our
    // `RangeReplaceableCollectionType` mapper.
    
    var variableList = field
    return mapField(&variableList, map: map)
}
```

#How To Use

`RealmAdaptor` conforms to `Adaptor` and `RealmMapping` conforms to `Mapping`. Use with the rest of [Crust](https://github.com/rexmas/Crust) just like any other `Mapping` and `Adaptor`.

E.g.
```swift
public class Company: Object {
    
    public let employees = List<Employee>()
    public dynamic var uuid: String = ""
    public dynamic var name: String = ""
    public dynamic var foundingDate: NSDate = NSDate()
    public dynamic var founder: Employee?
    public dynamic var pendingLawsuits: Int = 0
}

extension Company: Mappable { }

public class CompanyMapping : RealmMapping {
    
    public var adaptor: RealmAdaptor
    public var primaryKeys: Array<CRMappingKey> {
        return [ "uuid" ]
    }
    
    public required init(adaptor: RealmAdaptor) {
        self.adaptor = adaptor
    }
    
    public func mapping(inout tomap: Company, context: MappingContext) {
        let employeeMapping = EmployeeMapping(adaptor: self.adaptor)
        
        tomap.employees             <- .Mapping("employees", employeeMapping) >*<
        tomap.founder               <- .Mapping("founder", employeeMapping) >*<
        tomap.uuid                  <- "uuid" >*<
        tomap.name                  <- "name" >*<
        tomap.foundingDate          <- "data.founding_date"  >*<
        tomap.pendingLawsuits       <- "data.lawsuits.pending"  >*<
        context
    }
}
```

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
