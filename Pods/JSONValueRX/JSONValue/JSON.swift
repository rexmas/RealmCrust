import Foundation

public enum JSONValue : CustomStringConvertible {
    case JSONArray([JSONValue])
    case JSONObject([String : JSONValue])
    case JSONNumber(Double)
    case JSONString(String)
    case JSONBool(Bool)
    case JSONNull()
    
    public func values() -> AnyObject {
        switch self {
        case let .JSONArray(xs):
            return xs.map { $0.values() }
        case let .JSONObject(xs):
            return xs.mapValues { $0.values() }
        case let .JSONNumber(n):
            return n
        case let .JSONString(s):
            return s
        case let .JSONBool(b):
            return b
        case .JSONNull():
            return NSNull()
        }
    }
    
    public func valuesAsNSObjects() -> NSObject {
        switch self {
        case let .JSONArray(xs):
            return xs.map { $0.values() }
        case let .JSONObject(xs):
            return xs.mapValues { $0.values() }
        case let .JSONNumber(n):
            return NSNumber(double: n)
        case let .JSONString(s):
            return NSString(string: s)
        case let .JSONBool(b):
            return NSNumber(bool: b)
        case .JSONNull():
            return NSNull()
        }
    }
    
    public init<T>(array: Array<T>) throws {
        let jsonValues = try array.map {
            return try JSONValue(object: $0)
        }
        self = .JSONArray(jsonValues)
    }
    
    public init<V>(dict: Dictionary<String, V>) throws {
        var jsonValues = [String : JSONValue]()
        for (key, val) in dict {
            let x = try JSONValue(object: val)
            jsonValues[key] = x
        }
        self = .JSONObject(jsonValues)
    }
    
    // NOTE: Would be nice to figure out a generic recursive way of solving this.
    // Array<Dictionary<String, Any>> doesn't seem to work. Maybe case eval on generic param too?
    public init(object: Any) throws {
        switch object {
        case let array as Array<Any>:
            let jsonValues = try array.map {
                return try JSONValue(object: $0)
            }
            self = .JSONArray(jsonValues)
            
        case let array as NSArray:
            let jsonValues = try array.map {
                return try JSONValue(object: $0)
            }
            self = .JSONArray(jsonValues)
            
        case let dict as Dictionary<String, Any>:
            var jsonValues = [String : JSONValue]()
            for (key, val) in dict {
                let x = try JSONValue(object: val)
                jsonValues[key] = x
            }
            self = .JSONObject(jsonValues)
            
        case let dict as NSDictionary:
            var jsonValues = [String : JSONValue]()
            for (key, val) in dict {
                let x = try JSONValue(object: val)
                jsonValues[key as! String] = x
            }
            self = .JSONObject(jsonValues)
        
        case let val as NSNumber:
            if val.isBool {
                self = .JSONBool(val.boolValue)
            } else {
                self = .JSONNumber(val.doubleValue)
            }
            
        case let val as NSString:
            self = .JSONString(String(val))
            
        case is NSNull:
            self = .JSONNull()
            
        default:
            // TODO: Generate an enum of standard errors.
            let userInfo = [ NSLocalizedFailureReasonErrorKey : "\(object.dynamicType) cannot be converted to JSON" ]
            throw NSError(domain: "CRJSONErrorDomain", code: -1000, userInfo: userInfo)
        }
    }
    
    public func encode() throws -> NSData {
        return try NSJSONSerialization.dataWithJSONObject(self.values(), options: NSJSONWritingOptions(rawValue: 0))
    }
    
    public static func decode(data: NSData) throws -> JSONValue {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        return try JSONValue(object: json)
    }
    
    public static func decode(string: String) throws -> JSONValue {
        return try JSONValue.decode(string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    }
    
    public subscript(index: JSONKeypath) -> JSONValue? {
        get {
            return self[index.keyPath]
        }
        set(newValue) {
            self[index.keyPath] = newValue
        }
    }
    
    subscript(index: String) -> JSONValue? {
        get {
            let components = index.componentsSeparatedByString(".")
            if let result = self[components] {
                return result
            } else {
                return self[[index]]
            }
        }
        set(newValue) {
            let components = index.componentsSeparatedByString(".")
            self[components] = newValue
        }
    }
    
    public subscript(index: [String]) -> JSONValue? {
        get {
            guard let key = index.first else {
                return self
            }
            
            let keys = index.dropFirst()
            switch self {
            case .JSONObject(let obj):
                if let next = obj[key] {
                    return next[Array(keys)]
                } else {
                    return nil
                }
            case .JSONArray(let arr):
                return .JSONArray(arr.flatMap { $0[index] })
            default:
                return nil
            }
        }
        set (newValue) {
            guard let key = index.first else {
                return
            }
            
            if index.count == 1 {
                switch self {
                case .JSONObject(var obj):
                    if (newValue != nil) {
                        obj.updateValue(newValue!, forKey: key)
                    } else {
                        obj.removeValueForKey(key)
                    }
                    self = .JSONObject(obj)
                default:
                    return
                }
            }
            
            let keys = index.dropFirst()
            switch self {
            case .JSONObject(var obj):
                if var next = obj[key] {
                    next[Array(keys)] = newValue
                    obj.updateValue(next, forKey: key)
                    self = .JSONObject(obj)
                }
            default:
                return
            }
        }
    }
    
    public var description : String {
        switch self {
        case .JSONNull():
            return "JSONNull()"
        case let .JSONBool(b):
            return "JSONBool(\(b))"
        case let .JSONString(s):
            return "JSONString(\(s))"
        case let .JSONNumber(n):
            return "JSONNumber(\(n))"
        case let .JSONObject(o):
            return "JSONObject(\(o))"
        case let .JSONArray(a):
            return "JSONArray(\(a))"
        }
    }
}

// MARK: - Protocols
// MARK: - Hashable, Equatable

extension JSONValue : Hashable {
    
    static let prime = 31
    static let truePrime = 1231;
    static let falsePrime = 1237;
    
    public var hashValue: Int {
        switch self {
        case .JSONNull():
            return JSONValue.prime
        case let .JSONBool(b):
            return b ? JSONValue.truePrime : JSONValue.falsePrime
        case let .JSONString(s):
            return s.hashValue
        case let .JSONNumber(n):
            return n.hashValue
        case let .JSONObject(obj):
            return obj.reduce(1, combine: { (accum: Int, pair: (key: String, val: JSONValue)) -> Int in
                return accum.hashValue ^ pair.key.hashValue ^ pair.val.hashValue.byteSwapped
            })
        case let .JSONArray(xs):
            return xs.reduce(3, combine: { (accum: Int, val: JSONValue) -> Int in
                return (accum.hashValue &* JSONValue.prime) ^ val.hashValue
            })
        }
    }
}

public func ==(lhs : JSONValue, rhs : JSONValue) -> Bool {
    switch (lhs, rhs) {
    case (.JSONNull(), .JSONNull()):
        return true
    case let (.JSONBool(l), .JSONBool(r)) where l == r:
        return true
    case let (.JSONString(l), .JSONString(r)) where l == r:
        return true
    case let (.JSONNumber(l), .JSONNumber(r)) where l == r:
        return true
    case let (.JSONObject(l), .JSONObject(r))
        where l.elementsEqual(r, isEquivalent: {
            (v1: (String, JSONValue), v2: (String, JSONValue)) in
            v1.0 == v2.0 && v1.1 == v2.1
        }):
        return true
    case let (.JSONArray(l), .JSONArray(r)) where l.elementsEqual(r, isEquivalent: { $0 == $1 }):
        return true
    default:
        return false
    }
}

public func !=(lhs : JSONValue, rhs : JSONValue) -> Bool {
    return !(lhs == rhs)
}

// MARK: - JSONKeypath

public protocol JSONKeypath {
    var keyPath: String { get }
}

extension String : JSONKeypath {
    public var keyPath: String {
        return self
    }
}

extension Int : JSONKeypath {
    public var keyPath: String {
        return String(self)
    }
}
