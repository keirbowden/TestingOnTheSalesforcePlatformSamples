@isTest
public class CrossTransactionTestDataFail {
    private static Map<String, Opportunity> testOpps;

    @testSetup 
    static void SetupOpportunities()
    {
        testOpps=new Map<String, Opportunity>();
        for (Integer idx=0; idx<100; idx++)
        {
            String oppName='Unit Test' + idx;
            testOpps.put(oppName, new Opportunity(Name=oppName,
                                         Amount=100000+(idx*1000),
                                         CloseDate=System.today().addDays(idx),
                                         StageName='Prospecting'));
        }
        insert testOpps.values();
    }

    @isTest
    static void TestSetupOfOpportunities()
    {
        for (String name : testOpps.keySet())
        {
            System.debug('Opp = ' + testOpps.get(name));
        }
    }

}