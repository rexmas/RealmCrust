import Foundation
import JSONValueRX

// MARK: - Merge right into tuple operator definition

infix operator >*< { associativity right }

public func >*< <T, U>(left: T, right: U) -> (T, U) {
    return (left, right)
}

public func >*< <T: JSONKeypath, U>(left: T, right: U) -> (JSONKeypath, U) {
    return (left, right)
}

// MARK: - Map value operator definition

infix operator <- { associativity right }

// Map arbitrary object.

public func <- <T: JSONable, C: MappingContext where T == T.ConversionType>(inout field: T, map:(key: JSONKeypath, context: C)) -> C {
    return mapField(&field, map: map)
}

// Map a Mappable.
public func <- <T, U: Mapping, C: MappingContext where U.MappedObject == T>(inout field: T, map:(key: KeyExtensions<U>, context: C)) -> C {
    return mapFieldWithMapping(&field, map: map)
}

public func <- <T: JSONable, U: Transform, C: MappingContext where U.MappedObject == T, T == T.ConversionType>(inout field: T, map:(key: KeyExtensions<U>, context: C)) -> C {
    return mapFieldWithMapping(&field, map: map)
}

// NOTE: Must supply two separate versions for optional and non-optional types or we'll have to continuously
// guard against unsafe nil assignments.

public func <- <T: JSONable, C: MappingContext where T == T.ConversionType>(inout field: T?, map:(key: JSONKeypath, context: C)) -> C {
    return mapField(&field, map: map)
}

public func <- <T, U: Mapping, C: MappingContext where U.MappedObject == T>(inout field: T?, map:(key: KeyExtensions<U>, context: C)) -> C {
    return mapFieldWithMapping(&field, map: map)
}

public func <- <T: JSONable, U: Transform, C: MappingContext where U.MappedObject == T, T == T.ConversionType>(inout field: T?, map:(key: KeyExtensions<U>, context: C)) -> C {
    return mapFieldWithMapping(&field, map: map)
}

// MARK: - Map funcs

// Arbitrary object.
public func mapField<T: JSONable, C: MappingContext where T == T.ConversionType>(inout field: T, map:(key: JSONKeypath, context: C)) -> C {
    
    guard map.context.error == nil else {
        return map.context
    }
    
    switch map.context.dir {
    case .ToJSON:
        let json = map.context.json
        map.context.json = mapToJson(json, fromField: field, viaKey: map.key)
    case .FromJSON:
        do {
            if let baseJSON = map.context.json[map.key] {
                try mapFromJson(baseJSON, toField: &field)
            } else {
                let userInfo = [ NSLocalizedFailureReasonErrorKey : "Could not find value in JSON \(map.context.json) from keyPath \(map.key)" ]
                throw NSError(domain: CRMappingDomain, code: 0, userInfo: userInfo)
            }
        } catch let error as NSError {
            map.context.error = error
        }
    }
    
    return map.context
}

// Arbitrary Optional.
public func mapField<T: JSONable, C: MappingContext where T == T.ConversionType>(inout field: T?, map:(key: JSONKeypath, context: C)) -> C {
    
    guard map.context.error == nil else {
        return map.context
    }
    
    switch map.context.dir {
    case .ToJSON:
        let json = map.context.json
        map.context.json = mapToJson(json, fromField: field, viaKey: map.key)
    case .FromJSON:
        do {
            if let baseJSON = map.context.json[map.key] {
                try mapFromJson(baseJSON, toField: &field)
            } else {
                let userInfo = [ NSLocalizedFailureReasonErrorKey : "Value not present in JSON \(map.context.json) from keyPath \(map.key)" ]
                throw NSError(domain: CRMappingDomain, code: 0, userInfo: userInfo)
            }
        } catch let error as NSError {
            map.context.error = error
        }
    }
    
    return map.context
}

// Mappable.
public func mapFieldWithMapping<T, U: Mapping, C: MappingContext where U.MappedObject == T>(inout field: T, map:(key: KeyExtensions<U>, context: C)) -> C {
    
    guard map.context.error == nil else {
        return map.context
    }
    
    guard case .Mapping(let key, let mapping) = map.key else {
        let userInfo = [ NSLocalizedFailureReasonErrorKey : "Expected KeyExtension.Mapping to map type \(T.self)" ]
        map.context.error = NSError(domain: CRMappingDomain, code: -1000, userInfo: userInfo)
        return map.context
    }
    
    do {
        switch map.context.dir {
        case .ToJSON:
            let json = map.context.json
            try map.context.json = mapToJson(json, fromField: field, viaKey: key, mapping: mapping)
        case .FromJSON:
            if let baseJSON = map.context.json[map.key] {
                try mapFromJson(baseJSON, toField: &field, mapping: mapping, context: map.context)
            } else {
                let userInfo = [ NSLocalizedFailureReasonErrorKey : "JSON at key path \(map.key) does not exist to map from" ]
                throw NSError(domain: CRMappingDomain, code: 0, userInfo: userInfo)
            }
        }
    } catch let error as NSError {
        map.context.error = error
    }
    
    return map.context
}

// TODO: Maybe we can just make Optional: Mappable and then this redudancy can safely go away...
public func mapFieldWithMapping<T, U: Mapping, C: MappingContext where U.MappedObject == T>(inout field: T?, map:(key: KeyExtensions<U>, context: C)) -> C {
    
    guard map.context.error == nil else {
        return map.context
    }
    
    guard case .Mapping(let key, let mapping) = map.key else {
        let userInfo = [ NSLocalizedFailureReasonErrorKey : "Expected KeyExtension.Mapping to map type \(T.self)" ]
        map.context.error = NSError(domain: CRMappingDomain, code: -1000, userInfo: userInfo)
        return map.context
    }
    
    do {
        switch map.context.dir {
        case .ToJSON:
            let json = map.context.json
            try map.context.json = mapToJson(json, fromField: field, viaKey: key, mapping: mapping)
        case .FromJSON:
            if let baseJSON = map.context.json[map.key] {
                try mapFromJson(baseJSON, toField: &field, mapping: mapping, context: map.context)
            } else {
                let userInfo = [ NSLocalizedFailureReasonErrorKey : "JSON at key path \(map.key) does not exist to map from" ]
                throw NSError(domain: CRMappingDomain, code: 0, userInfo: userInfo)
            }
        }
    } catch let error as NSError {
        map.context.error = error
    }
    
    return map.context
}

// MARK: - To JSON

private func mapToJson<T: JSONable where T == T.ConversionType>(var json: JSONValue, fromField field: T?, viaKey key: JSONKeypath) -> JSONValue {
    
    if let field = field {
        json[key] = T.toJSON(field)
    } else {
        json[key] = .JSONNull()
    }
    
    return json
}

private func mapToJson<T, U: Mapping where U.MappedObject == T>(var json: JSONValue, fromField field: T?, viaKey key: CRMappingKey, mapping: U) throws -> JSONValue {
    
    guard let field = field else {
        json[key] = .JSONNull()
        return json
    }
    
    json[key] = try CRMapper<T, U>().mapFromObjectToJSON(field, mapping: mapping)
    return json
}

// MARK: - From JSON

private func mapFromJson<T: JSONable where T.ConversionType == T>(json: JSONValue, inout toField field: T) throws {
    
    if let fromJson = T.fromJSON(json) {
        field = fromJson
    } else {
        let userInfo = [ NSLocalizedFailureReasonErrorKey : "Conversion of JSON \(json) to type \(T.self) failed" ]
        throw NSError(domain: CRMappingDomain, code: -1, userInfo: userInfo)
    }
}

private func mapFromJson<T: JSONable where T.ConversionType == T>(json: JSONValue, inout toField field: T?) throws {
    
    if case .JSONNull = json {
        field = nil
        return
    }
    
    if let fromJson = T.fromJSON(json) {
        field = fromJson
    } else {
        let userInfo = [ NSLocalizedFailureReasonErrorKey : "Conversion of JSON \(json) to type \(T.self) failed" ]
        throw NSError(domain: CRMappingDomain, code: -1, userInfo: userInfo)
    }
}

private func mapFromJson<T, U: Mapping where U.MappedObject == T>(json: JSONValue, inout toField field: T, mapping: U, context: MappingContext) throws {
    
    let mapper = CRMapper<T, U>()
    field = try mapper.mapFromJSONToExistingObject(json, mapping: mapping, parentContext: context)
}

private func mapFromJson<T, U: Mapping where U.MappedObject == T>(json: JSONValue, inout toField field: T?, mapping: U, context: MappingContext) throws {
    
    if case .JSONNull = json {
        field = nil
        return
    }
    
    let mapper = CRMapper<T, U>()
    field = try mapper.mapFromJSONToExistingObject(json, mapping: mapping, parentContext: context)
}

// MARK: - RangeReplaceableCollectionType (Array and Realm List follow this protocol)

public func <- <T, U: Mapping, V: RangeReplaceableCollectionType, C: MappingContext where U.MappedObject == T, V.Generator.Element == T, T: Equatable>(inout field: V, map:(key: KeyExtensions<U>, context: C)) -> C {
    
    return mapField(&field, map: map)
}

public func mapField<T, U: Mapping, V: RangeReplaceableCollectionType, C: MappingContext where U.MappedObject == T, V.Generator.Element == T, T: Equatable>(inout field: V, map:(key: KeyExtensions<U>, context: C)) -> C {
    
    guard map.context.error == nil else {
        return map.context
    }
    
    let mapping = map.key.mapping
    do {
        switch map.context.dir {
        case .ToJSON:
            let json = map.context.json
            try map.context.json = mapToJson(json, fromField: field, viaKey: map.key, mapping: mapping)
        case .FromJSON:
            if let baseJSON = map.context.json[map.key] {
                let allowDupes = map.key.options.contains(.AllowDuplicatesInCollection)
                try mapFromJson(baseJSON, toField: &field, mapping: mapping, context: map.context, allowDuplicates: allowDupes)
            } else {
                let userInfo = [ NSLocalizedFailureReasonErrorKey : "JSON at key path \(map.key) does not exist to map from" ]
                throw NSError(domain: CRMappingDomain, code: 0, userInfo: userInfo)
            }
        }
    } catch let error as NSError {
        map.context.error = error
    }
    
    return map.context
}

private func mapToJson<T, U: Mapping, V: RangeReplaceableCollectionType where U.MappedObject == T, V.Generator.Element == T>(var json: JSONValue, fromField field: V, viaKey key: CRMappingKey, mapping: U) throws -> JSONValue {
    
    let results = try field.map {
        try CRMapper<T, U>().mapFromObjectToJSON($0, mapping: mapping)
    }
    json[key] = .JSONArray(results)
    
    return json
}

private func mapFromJson<T, U: Mapping, V: RangeReplaceableCollectionType where U.MappedObject == T, V.Generator.Element == T, T: Equatable>(json: JSONValue, inout toField field: V, mapping: U, context: MappingContext, allowDuplicates: Bool) throws {
    
    if case .JSONArray(let xs) = json {
        let mapper = CRMapper<T, U>()
        var results = Array<T>()
        for x in xs {
            if !allowDuplicates {
                if let obj = try mapping.getExistingInstanceFromJSON(x) {
                    if results.contains(obj) {
                        continue
                    }
                }
            }
            
            let obj = try mapper.mapFromJSONToExistingObject(x, mapping: mapping, parentContext: context)
            results.append(obj)
        }
        field.appendContentsOf(results)
    } else {
        let userInfo = [ NSLocalizedFailureReasonErrorKey : "Trying to map json of type \(json.dynamicType) to \(V.self)<\(T.self)>" ]
        throw NSError(domain: CRMappingDomain, code: -1, userInfo: userInfo)
    }
}