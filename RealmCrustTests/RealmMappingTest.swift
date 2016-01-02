import XCTest
import Crust
import RealmSwift

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


