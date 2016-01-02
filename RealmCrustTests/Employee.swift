import RealmSwift
import Crust

public class Employee: Object {
    
    public dynamic var employer: Company?
    public dynamic var uuid: String = ""
    public dynamic var name: String = ""
    public dynamic var joinDate: NSDate = NSDate()
    public dynamic var salary: Int = 0
    public dynamic var isEmployeeOfMonth: Bool = false
    public dynamic var percentYearlyRaise: Double = 0.0
}

extension Employee: Mappable { }

public class EmployeeMapping : RealmMapping {
    
    public var adaptor: RealmAdaptor
    public var primaryKeys: Array<CRMappingKey> {
        return [ "uuid" ]
    }
    
    public required init(adaptor: RealmAdaptor) {
        self.adaptor = adaptor
    }
    
    public func mapping(inout tomap: Employee, context: MappingContext) {
        let companyMapping = CompanyMapping(adaptor: self.adaptor)
        
        tomap.employer              <- .Mapping("company", companyMapping) >*<
            tomap.joinDate              <- "joinDate"  >*<
            tomap.uuid                  <- "uuid" >*<
            tomap.name                  <- "name" >*<
            tomap.salary                <- "data.salary"  >*<
            tomap.isEmployeeOfMonth     <- "data.is_employee_of_month"  >*<
            tomap.percentYearlyRaise    <- "data.percent_yearly_raise" >*<
        context
    }
}
