import XCTest
import Crust
import JSONValueRX
import RealmSwift

class EmployeeMappingTests: RealmMappingTest {
    
    func testJsonToEmployee() {
        
        XCTAssertEqual(realm!.objects(Employee).count, 0)
        let stub = EmployeeStub()
        let json = try! JSONValue(object: stub.generateJsonObject())
        let mapper = CRMapper<Employee, EmployeeMapping>()
        let object = try! mapper.mapFromJSONToNewObject(json, mapping: EmployeeMapping(adaptor: adaptor!))
        
        try! self.adaptor!.saveObjects([ object ])
        
        XCTAssertEqual(realm!.objects(Employee).count, 1)
        XCTAssertTrue(stub.matches(object))
    }
}
