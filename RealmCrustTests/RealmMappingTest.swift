import XCTest
import Crust
import RealmCrust
import RealmSwift

/// Instructions:
/// 1. `import Crust` and `import RealmCrust` dependencies.
/// 2. Include this section of code in your app/lib and uncomment.
/// This will allow our `RealmMapping` and `RealmAdaptor` to be used with Crust.

public protocol RealmMapping : Mapping {
    init(adaptor: RealmAdaptor)
}
extension RealmAdaptor : Adaptor { }

public func <- <T: Mappable, U: Mapping, C: MappingContext where U.MappedObject == T>(field: List<T>, map:(key: KeyExtensions<U>, context: C)) -> C {
    
    // Realm specifies that List "must be declared with 'let'". Seems to actually work either way in practice, but for safety
    // we're going to include a List mapper that accepts fields with a 'let' declaration and forward to our
    // `RangeReplaceableCollectionType` mapper.
    
    var variableList = field
    return mapField(&variableList, map: map)
}

class RealmMappingTest: XCTestCase {
    var realm: Realm?
    var adaptor: RealmAdaptor?
    
    override func setUp() {
        super.setUp()
        
        // Use an in-memory Realm identified by the name of the current test.
        // This ensures that each test can't accidentally access or modify the data
        // from other tests or the application itself, and because they're in-memory,
        // there's nothing that needs to be cleaned up.
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        realm = try! Realm()
        
        adaptor = RealmAdaptor(realm: realm!)
    }
}


