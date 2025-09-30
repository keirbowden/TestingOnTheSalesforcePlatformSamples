public with sharing class LeadUtils {
    public static String STALE_STATUS='Stale';

    public static void MarkLeadsAsNeglectedAndUpdate(List<Lead> neglectedLeads) {
        for (Lead neglectedLead : neglectedLeads) {
            neglectedLead.status=STALE_STATUS;
        }

        update neglectedLeads;
    }
}