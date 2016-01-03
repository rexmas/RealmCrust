import Foundation
import JSONValueRX

public enum MappingDirection {
    case FromJSON
    case ToJSON
}

internal let CRMappingDomain = "CRMappingDomain"

public protocol CRMappingKey : JSONKeypath { }

extension String : CRMappingKey { }
extension Int : CRMappingKey { }

public class MappingContext {
    public var json: JSONValue
    public var object: Mappable
    public private(set) var dir: MappingDirection
    public internal(set) var error: ErrorType?
    public internal(set) var parent: MappingContext? = nil
    
    init(withObject object:Mappable, json: JSONValue, direction: MappingDirection) {
        self.dir = direction
        self.object = object
        self.json = json
    }
}

/// Method caller used to perform mappings.
public struct CRMapper<T: Mappable, U: Mapping where U.MappedObject == T> {
    
    public init() { }
    
    public func mapFromJSONToNewObject(json: JSONValue, mapping: U) throws -> T {
        let object = try mapping.getNewInstance()
        return try mapFromJSON(json, toObject: object, mapping: mapping)
    }
    
    public func mapFromJSONToExistingObject(json: JSONValue, mapping: U, parentContext: MappingContext? = nil) throws -> T {
        var object = try mapping.getExistingInstanceFromJSON(json)
        if object == nil {
            object = try mapping.getNewInstance()
        }
        return try mapFromJSON(json, toObject: object!, mapping: mapping, parentContext: parentContext)
    }
    
    public func mapFromJSON(json: JSONValue, var toObject object: T, mapping: U, parentContext: MappingContext? = nil) throws -> T {
        let context = MappingContext(withObject: object, json: json, direction: MappingDirection.FromJSON)
        context.parent = parentContext
        try mapping.performMappingWithObject(&object, context: context)
        return object
    }
    
    public func mapFromObjectToJSON(var object: T, mapping: U) throws -> JSONValue {
        let context = MappingContext(withObject: object, json: JSONValue.JSONObject([:]), direction: MappingDirection.ToJSON)
        try mapping.performMappingWithObject(&object, context: context)
        return context.json
    }
}

public extension Mapping {
    func getExistingInstanceFromJSON(json: JSONValue) throws -> MappedObject? {
        
        // NOTE: This sux but `MappedObject: AdaptorKind.BaseType` as a type constraint throws a compiler error as of 7.1 Xcode
        // and `MappedObject == AdaptorKind.BaseType` doesn't work with sub-types (i.e. expects MappedObject to be that exact type)
        guard MappedObject.self is AdaptorKind.BaseType.Type else {
            let userInfo = [ NSLocalizedFailureReasonErrorKey : "Type of object \(MappedObject.self) is not a subtype of \(AdaptorKind.BaseType.self)" ]
            throw NSError(domain: CRMappingDomain, code: -1, userInfo: userInfo)
        }
        
        let primaryKeys = self.primaryKeys
        var keyValues = [ String : CVarArgType ]()
        try primaryKeys.forEach {
            let keyPath = $0.keyPath
            if let val = json[keyPath] {
                keyValues[keyPath] = val.valuesAsNSObjects()
            } else {
                let userInfo = [ NSLocalizedFailureReasonErrorKey : "Primary key of \(keyPath) does not exist in JSON but is expected from mapping \(Self.self)" ]
                throw NSError(domain: CRMappingDomain, code: -1, userInfo: userInfo)
            }
        }
        
        let obj = self.adaptor.fetchObjectsWithType(MappedObject.self as! AdaptorKind.BaseType.Type, keyValues: keyValues).first
        return obj as! MappedObject?
    }
    
    func getNewInstance() throws -> MappedObject {
        
        // NOTE: This sux but `MappedObject: AdaptorKind.BaseType` as a type constraint throws a compiler error as of 7.1 Xcode
        // and `MappedObject == AdaptorKind.BaseType` doesn't work with sub-types (i.e. expects MappedObject to be that exact type)
        guard MappedObject.self is AdaptorKind.BaseType.Type else {
            let userInfo = [ NSLocalizedFailureReasonErrorKey : "Type of object \(MappedObject.self) is not a subtype of \(AdaptorKind.BaseType.self)" ]
            throw NSError(domain: CRMappingDomain, code: -1, userInfo: userInfo)
        }
        
        return try self.adaptor.createObject(MappedObject.self as! AdaptorKind.BaseType.Type) as! MappedObject
    }
    
    internal func startMappingWithContext(context: MappingContext) throws {
        if context.parent == nil {
            var underlyingError: NSError?
            do {
                try self.adaptor.mappingBegins()
            } catch let err as NSError {    // We can handle NSErrors higher up.
                underlyingError = err
            } catch {
                var userInfo = Dictionary<NSObject, AnyObject>()
                userInfo[NSLocalizedFailureReasonErrorKey] = "Errored during mappingBegins for adaptor \(self.adaptor)"
                userInfo[NSUnderlyingErrorKey] = underlyingError
                throw NSError(domain: CRMappingDomain, code: -1, userInfo: userInfo)
            }
        }
    }
    
    internal func endMappingWithContext(context: MappingContext) throws {
        if context.parent == nil {
            var underlyingError: NSError?
            do {
                try self.adaptor.mappingEnded()
            } catch let err as NSError {
                underlyingError = err
            } catch {
                var userInfo = Dictionary<NSObject, AnyObject>()
                userInfo[NSLocalizedFailureReasonErrorKey] = "Errored during mappingEnded for adaptor \(self.adaptor)"
                userInfo[NSUnderlyingErrorKey] = underlyingError
                throw NSError(domain: CRMappingDomain, code: -1, userInfo: userInfo)
            }
        }
    }
    
    public func executeMappingWithObject(inout object: MappedObject, context: MappingContext) {
        self.mapping(&object, context: context)
    }
    
    internal func performMappingWithObject(inout object: MappedObject, context: MappingContext) throws {
        
        try self.startMappingWithContext(context)
        
        self.executeMappingWithObject(&object, context: context)
        
        if let error = context.error {
            if context.parent == nil {
                self.adaptor.mappingErrored(error)
            }
            throw error
        }
        
        try self.endMappingWithContext(context)
        
        context.object = object
    }
}

// For Network lib have something along the lines of. Will need to properly handle the typing constraints.
// func registerMapping(mapping: Mapping, forPath path: URLPath)
