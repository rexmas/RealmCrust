import Foundation
import Crust

class EmployeeStub {
    
    var employer: CompanyStub?
    var uuid: String = NSUUID().UUIDString
    var name: String = "John"
    var joinDate: NSDate = NSDate()
    var salary: NSNumber = 44                   // Int64
    var isEmployeeOfMonth: NSNumber = false     // Bool
    var percentYearlyRaise: NSNumber = 0.5      // Double
    
    init() { }
    
    func copy() -> EmployeeStub {
        let copy = EmployeeStub()
        copy.employer = employer?.copy()
        copy.uuid = uuid
        copy.name = name
        copy.joinDate = joinDate.copy() as! NSDate
        copy.salary = salary.copy() as! NSNumber
        copy.isEmployeeOfMonth = isEmployeeOfMonth.copy() as! NSNumber
        copy.percentYearlyRaise = percentYearlyRaise.copy() as! NSNumber
        
        return copy
    }
    
    func generateJsonObject() -> Dictionary<String, AnyObject> {
        let company = employer?.generateJsonObject()
        return [
            "uuid" : uuid,
            "name" : name,
            "joinDate" : joinDate.toISOString(),
            "company" :  company == nil ? NSNull() : company! as NSDictionary,
            "data" : [
                "salary" : salary,
                "is_employee_of_month" : isEmployeeOfMonth,
                "percent_yearly_raise" : percentYearlyRaise
            ]
        ]
    }
    
    func matches(object: Employee) -> Bool {
        var matches = true
        matches &&= uuid == object.uuid
        matches &&= name == object.name
        matches &&= floor(joinDate.timeIntervalSinceReferenceDate) == object.joinDate.timeIntervalSinceReferenceDate
        matches &&= salary == object.salary
        matches &&= isEmployeeOfMonth == object.isEmployeeOfMonth
        matches &&= percentYearlyRaise == object.percentYearlyRaise
        if let employer = employer {
            matches &&= (employer.matches(object.employer!))
        } else if object.employer != nil {
            return false
        }
        
        return matches
    }
}
