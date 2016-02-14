import Crust
import RealmCrust
import RealmSwift

public class Company: Object {
    
    public let employees = List<Employee>()
    public dynamic var uuid: String = ""
    public dynamic var name: String = ""
    public dynamic var foundingDate: NSDate = NSDate()
    public dynamic var founder: Employee?
    public dynamic var pendingLawsuits: Int = 0
    
    public override class func primaryKey() -> String? {
        return "uuid"
    }
}

public class CompanyMapping : RealmMapping {
    
    public var adaptor: RealmAdaptor
    public var primaryKeys: Dictionary<String, CRMappingKey>? {
        return [ "uuid" : "data.uuid" ]
    }
    
    public required init(adaptor: RealmAdaptor) {
        self.adaptor = adaptor
    }
    
    public func mapping(inout tomap: Company, context: MappingContext) {
        let employeeMapping = EmployeeMapping(adaptor: self.adaptor)
        
        tomap.employees             <- .Mapping("employees", employeeMapping) >*<
        tomap.founder               <- .Mapping("founder", employeeMapping) >*<
        tomap.uuid                  <- "data.uuid" >*<
        tomap.name                  <- "name" >*<
        tomap.foundingDate          <- "data.founding_date"  >*<
        tomap.pendingLawsuits       <- "data.lawsuits.pending"  >*<
        context
    }
}

public class CompanyMappingWithDupes : CompanyMapping {
    
    public override func mapping(inout tomap: Company, context: MappingContext) {
        let employeeMapping = EmployeeMapping(adaptor: self.adaptor)
        let mappingExtension = KeyExtensions.Mapping("employees", employeeMapping)
        
        tomap.employees             <- .MappingOptions(mappingExtension, [ .AllowDuplicatesInCollection ]) >*<
        tomap.founder               <- .Mapping("founder", employeeMapping) >*<
        tomap.uuid                  <- "data.uuid" >*<
        tomap.name                  <- "name" >*<
        tomap.foundingDate          <- "data.founding_date"  >*<
        tomap.pendingLawsuits       <- "data.lawsuits.pending"  >*<
        context
    }
}
