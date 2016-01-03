import Foundation

extension NSNumber {
    
    var isBool : Bool {
        
        let trueNumber = NSNumber(bool: true)
        let falseNumber = NSNumber(bool: false)
        let trueObjCType = String.fromCString(trueNumber.objCType)
        let falseObjCType = String.fromCString(falseNumber.objCType)
        
        let objCType = String.fromCString(self.objCType)
        let isTrueNumber = (self.compare(trueNumber) == NSComparisonResult.OrderedSame && objCType == trueObjCType)
        let isFalseNumber = (self.compare(falseNumber) == NSComparisonResult.OrderedSame && objCType == falseObjCType)
        
        return isTrueNumber || isFalseNumber
    }
}

extension Dictionary {
    
    func mapValues<OutValue>(@noescape transform: Value throws -> OutValue) rethrows -> [Key : OutValue] {
        
        var outDict = [Key : OutValue]()
        try self.forEach { (key, value) in
            outDict[key] = try transform(value)
        }
        return outDict
    }
}

// Consider using SwiftDate library if requirements increase.
public extension NSDateFormatter {
    
    class func ISODateFormatter() -> NSDateFormatter {
        struct Static {
            static let dateFormatter = NSDateFormatter()
            static var onceToken: dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            Static.dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            Static.dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
            Static.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        }
        
        return Static.dateFormatter
    }
}

public extension NSDate {
    
    class func fromISOString(ISOString: String) -> NSDate? {
        let dateFromatter = NSDateFormatter.ISODateFormatter()
        return dateFromatter.dateFromString(ISOString)
    }
    
    func toISOString() -> String {
        let dateFromatter = NSDateFormatter.ISODateFormatter()
        return dateFromatter.stringFromDate(self)
    }
}
