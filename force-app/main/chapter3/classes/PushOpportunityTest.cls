@isTest
private class PushOpportunityTest {
    static testMethod void TestPushCloseDateOut1WeekNoAssert()
    {
        Opportunity testOpp=new Opportunity(Name='Unit Test',
                                            Amount=10000,
                                            StageName='Prospecting',
                                            CloseDate=System.today());

        PushOpportunity.PushCloseDateOut1Week(testOpp);
    }

        static testMethod void TestPushCloseDateOut1Week()
    {
        Date origDate=System.today();
        Date expectedDate=origDate.addDays(7);

        Opportunity testOpp=new Opportunity(Name='Unit Test',
                                            Amount=10000,
                                            StageName='Prospecting',
                                            CloseDate=origDate);

        PushOpportunity.PushCloseDateOut1Week(testOpp);

        Assert.areEqual(expectedDate, testOpp.CloseDate,
                       'Close date should have moved out 7 days');
    }

}