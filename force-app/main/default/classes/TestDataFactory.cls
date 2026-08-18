@isTest
public class TestDataFactory {

    public static List<Lead> buildHotLeads(Integer howMany) {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < howMany; i++) {
            leads.add(new Lead(
                LastName = 'Bulk Lead ' + i,
                Company = 'Bulk Corp ' + i,
                NumberOfEmployees = 600,
                Email = 'bulk' + i + '@example.com',
                Phone = '1199999' + i
            ));
        }
        return leads;
    }
}