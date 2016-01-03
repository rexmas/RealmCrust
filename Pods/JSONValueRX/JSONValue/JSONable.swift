import Foundation

// MARK: - JSONable

public protocol JSONDecodable {
    typealias ConversionType = Self
    static func fromJSON(x : JSONValue) -> ConversionType?
}

public protocol JSONEncodable {
    typealias ConversionType
    static func toJSON(x : ConversionType) -> JSONValue
}

public protocol JSONable : JSONDecodable, JSONEncodable { }

extension Dictionary : JSONable {
    public typealias ConversionType = Dictionary<String, Value>
    public static func fromJSON(x: JSONValue) -> Dictionary.ConversionType? {
        switch x {
        case .JSONObject:
            return x.values() as? Dictionary<String, Value>
        default:
            return nil
        }
    }
    
    public static func toJSON(x: Dictionary.ConversionType) -> JSONValue {
        do {
            return try JSONValue(dict: x)
        } catch {
            return JSONValue.JSONNull()
        }
    }
}

extension Array : JSONable {
    public static func fromJSON(x: JSONValue) -> Array? {
        switch x {
        case .JSONArray:
            return x.values() as? Array
        default:
            return nil
        }
    }
    
    public static func toJSON(x: Array) -> JSONValue {
        do {
            return try JSONValue(array: x)
        } catch {
            return JSONValue.JSONNull()
        }
    }
}

extension Bool : JSONable {
    public static func fromJSON(x : JSONValue) -> Bool? {
        switch x {
        case let .JSONBool(n):
            return n
        case .JSONNumber(0):
            return false
        case .JSONNumber(1):
            return true
        default:
            return nil
        }
    }
    
    public static func toJSON(xs : Bool) -> JSONValue {
        return JSONValue.JSONNumber(Double(xs))
    }
}

extension Int : JSONable {
    public static func fromJSON(x : JSONValue) -> Int? {
        switch x {
        case let .JSONNumber(n):
            return Int(n)
        default:
            return nil
        }
    }
    
    public static func toJSON(xs : Int) -> JSONValue {
        return JSONValue.JSONNumber(Double(xs))
    }
}

extension Double : JSONable {
    public static func fromJSON(x : JSONValue) -> Double? {
        switch x {
        case let .JSONNumber(n):
            return n
        default:
            return nil
        }
    }
    
    public static func toJSON(xs : Double) -> JSONValue {
        return JSONValue.JSONNumber(xs)
    }
}

extension NSNumber : JSONable {
    public class func fromJSON(x : JSONValue) -> NSNumber? {
        switch x {
        case let .JSONNumber(n):
            return NSNumber(double: n)
        default:
            return nil
        }
    }
    
    public class func toJSON(x : NSNumber) -> JSONValue {
        return JSONValue.JSONNumber(Double(x))
    }
}

extension String : JSONable {
    public static func fromJSON(x : JSONValue) -> String? {
        switch x {
        case let .JSONString(n):
            return n
        default:
            return nil
        }
    }
    
    public static func toJSON(x : String) -> JSONValue {
        return JSONValue.JSONString(x)
    }
}

extension NSDate : JSONable {
    public static func fromJSON(x: JSONValue) -> NSDate? {
        switch x {
        case let .JSONString(string):
            return NSDate.fromISOString(string)
        default:
            return nil
        }
    }
    
    public static func toJSON(x: NSDate) -> JSONValue {
        return .JSONString(x.toISOString())
    }
}

extension NSNull : JSONable {
    public class func fromJSON(x : JSONValue) -> NSNull? {
        switch x {
        case .JSONNull():
            return NSNull()
        default:
            return nil
        }
    }
    
    public class func toJSON(xs : NSNull) -> JSONValue {
        return JSONValue.JSONNull()
    }
}
