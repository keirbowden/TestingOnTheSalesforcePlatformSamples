public class OpportunityUtils {
    public static String BIG_DEAL_MSG='<h1>Big Deal</h1>';

    public static void ProcessBigDeals(List<Opportunity> opps)
    {
        for (Opportunity opp : opps)
        {
             if (opp.Amount>250000)
             {
                 opp.Highlights__c=BIG_DEAL_MSG;
             }
        }
    }
}