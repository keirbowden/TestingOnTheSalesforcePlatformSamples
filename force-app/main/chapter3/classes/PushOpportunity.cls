public with sharing class PushOpportunity {
    public static void PushCloseDateOut1Week(Opportunity opp)
    {
        opp.CloseDate=opp.CloseDate.addDays(7);
    }
}