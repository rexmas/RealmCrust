import Foundation
import RealmSwift

public class RealmAdaptor {
    
    public typealias BaseType = Object
    public typealias ResultsType = Results<Object>
    
    var realm: Realm
    
    public init(realm: Realm) {
        self.realm = realm
    }
    
    public convenience init() throws {
        self.init(realm: try Realm())
    }
    
    public func mappingBegins() throws {
        self.realm.beginWrite()
    }
    
    public func mappingEnded() throws {
        try self.realm.commitWrite()
    }
    
    public func mappingErrored(error: ErrorType) {
        if self.realm.inWriteTransaction {
            self.realm.cancelWrite()
        }
    }
    
    public func createObject(objType: BaseType.Type) throws -> BaseType {
        let obj = objType.init()
        try self.saveObjects([ obj ])
        return obj
    }
    
    public func saveObjects(objects: [BaseType]) throws {
        let saveBlock = {
            self.realm.add(objects)
        }
        if self.realm.inWriteTransaction {
            saveBlock()
        } else {
            try self.realm.write(saveBlock)
        }
    }
    
    public func deleteObject(obj: BaseType) throws {
        let deleteBlock = {
            self.realm.delete(obj)
        }
        if self.realm.inWriteTransaction {
            deleteBlock()
        } else {
            try realm.write(deleteBlock)
        }
    }
    
    public func fetchObjectsWithType(type: BaseType.Type, keyValues: Dictionary<String, CVarArgType>) -> ResultsType {
        
        var predicates = Array<NSPredicate>()
        for (key, value) in keyValues {
            let predicate = NSPredicate(format: "%K == %@", key, value)
            predicates.append(predicate)
        }
        
        let andPredicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: predicates)
        
        return fetchObjectsWithType(type, predicate: andPredicate)
    }
    
    public func fetchObjectsWithType(type: BaseType.Type, predicate: NSPredicate) -> ResultsType {
        
        return realm.objects(type).filter(predicate)
    }
}

/// Instructions:
/// 1. `import Crust` and `import RealmCrust` dependencies.
/// 2. Include this section of code in your app/lib and uncomment.
/// This will allow our `RealmMapping` and `RealmAdaptor` to be used with Crust.

//public protocol RealmMapping {
//    init(adaptor: RealmAdaptor)
//}
//public extension RealmAdaptor : Adaptor { }

//public func <- <T: Mappable, U: Mapping, C: MappingContext where U.MappedObject == T>(field: List<T>, map:(key: KeyExtensions<U>, context: C)) -> C {

    // Realm specifies that List "must be declared with 'let'". Seems to actually work either way in practice, but for safety
    // we're going to include a List mapper that accepts fields with a 'let' declaration and forward to our
    // `RangeReplaceableCollectionType` mapper.
    
//    var variableList = field
//    return mapField(&variableList, map: map)
//}
