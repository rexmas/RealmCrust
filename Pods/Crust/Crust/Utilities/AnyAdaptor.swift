/// `MappedObject` type constraint required in `AnyMapping`.
public protocol AnyMappable : Mappable {
    init()
}

/// A `Mapping` that does not require an adaptor of `typealias AdaptorKind`.
/// Use for structs or classes that require no storage when mapping.
public protocol AnyMapping : Mapping {
    typealias AdaptorKind: AnyAdaptor = AnyAdaptorImp<MappedObject>
    typealias MappedObject: AnyMappable
}

public extension AnyMapping {
    var adaptor: AnyAdaptorImp<MappedObject> {
        return AnyAdaptorImp<MappedObject>()
    }
    
    var primaryKeys: Array<CRMappingKey> {
        return []
    }
}

/// Used internally to remove the need for structures conforming to `AnyMapping`
/// to specify a `typealias AdaptorKind`.
public struct AnyAdaptorImp<T: AnyMappable> : AnyAdaptor {
    public typealias BaseType = T
    public init() { }
}

/// A bare-bones `Adaptor`.
///
/// Conforming to `AnyAdaptor` automatically implements the requirements for `Adaptor`
/// outside of specifying the `BaseType`.
public protocol AnyAdaptor : Adaptor {
    typealias BaseType: AnyMappable
    typealias ResultsType = Array<BaseType>
}

public extension AnyAdaptor {
    
    func mappingBegins() throws { }
    func mappingEnded() throws { }
    func mappingErrored(error: ErrorType) { }
    
    func fetchObjectsWithType(type: BaseType.Type, keyValues: Dictionary<String, CVarArgType>) -> Array<BaseType> {
        return Array<BaseType>()
    }
    
    func createObject(objType: BaseType.Type) throws -> BaseType {
        return objType.init()
    }
    
    func deleteObject(obj: BaseType) throws { }
    func saveObjects(objects: [ BaseType ]) throws { }
}
