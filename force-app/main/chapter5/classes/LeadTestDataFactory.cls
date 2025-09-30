@isTest
public class LeadTestDataFactory {
    public static List<Lead> createLeads(Integer numLeads) {
        List<Lead> leads=new List<Lead>();
        for (Integer idx=0; idx<numLeads; idx++) {
            leads.add(new Lead(FirstName='Unit',
                               LastName='Test ' + idx,
                               Company='Testers Inc',
                               Status=MarkNeglectedLeadsBatch.NEW_STATUS));
        }
        
        return leads;
    }
}