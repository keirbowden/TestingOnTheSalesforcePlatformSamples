@IsTest
private class OpportunityUtilsTest {
    @IsTest static void TestProcessBigDealsZeroRecords() {
        List<Opportunity> opps=new List<Opportunity>();
        Test.startTest();
        OpportunityUtils.ProcessBigDeals(opps);
        Test.stopTest();

        Assert.areEqual(0, opps.size(), 'Should be no change to empty list of opportunities');
    }

    @IsTest static void TestProcessBigDealsSingleBigDeal() {
        List<Opportunity> opps=new List<Opportunity>();
        opps.add(new Opportunity(Name='Big Deal', Amount=250001));

        Test.startTest();
        OpportunityUtils.ProcessBigDeals(opps);
        Test.stopTest();

        Assert.areEqual(OpportunityUtils.BIG_DEAL_MSG, opps[0].Highlights__c, 
                        'Opportunity amount of 250001 should populate big deal message');

    }

    @IsTest static void TestProcessBigDealsSingleSmallDeal() {
        List<Opportunity> opps=new List<Opportunity>();
        opps.add(new Opportunity(Name='Small Deal', Amount=250000));

        Test.startTest();
        OpportunityUtils.ProcessBigDeals(opps);
        Test.stopTest();

        Assert.isNull(opps[0].Highlights__c, 
                      'Opportunity amount of 250000 should not populate big deal message');
    }

    @IsTest static void TestProcessBigDeals200Records() {
        List<Opportunity> opps=new List<Opportunity>();
        opps.add(new Opportunity(Name='Big Deal', Amount=250001));
        opps.add(new Opportunity(Name='Small Deal', Amount=250000));

        for (Integer idx=2; idx<200; idx++)
        {
            opps.add(new Opportunity(Name='Deal ' + idx, 
                                     Amount=(Math.random()*500000).intValue()));
        }

        Test.startTest();
        OpportunityUtils.ProcessBigDeals(opps);
        Test.stopTest();

        for (Opportunity opp : opps) {
            if (opp.Amount>250000) {
                Assert.areEqual(OpportunityUtils.BIG_DEAL_MSG, opp.Highlights__c, 
                                'Opportunity amount of ' + opp.Amount + ' should populate big deal message');

            }
            else {
                Assert.isNull(opp.Highlights__c, 
                      'Opportunity amount of 250000 should not populate big deal message');        
            }
        }
    }

    @IsTest static void TestProcessBigDealsNullInput() {
        Test.startTest();
        try {
            OpportunityUtils.ProcessBigDeals(null);
            Assert.fail('Null collection of opportunities should throw exception');
        }
        catch (NullPointerException exc) {
            // expected
        }
        Test.stopTest();
    }

    @IsTest static void TestProcessBigDealsNullOpportunity() {
        List<Opportunity> opps=new List<Opportunity>();
        opps.add(new Opportunity(Name='Big Deal', Amount=250001));
        opps.add(new Opportunity(Name='Small Deal', Amount=250000));
        opps.add(null);

        Test.startTest();
        try {
            OpportunityUtils.ProcessBigDeals(opps);
            Assert.fail('Null element should throw exception');
        }
        catch (NullPointerException exc) {
            // expected
        }
        Test.stopTest();
    }

    @IsTest static void TestProcessBigDealsNullAmount() {
        List<Opportunity> opps=new List<Opportunity>();
        opps.add(new Opportunity(Name='Big Deal', Amount=null));

        Test.startTest();
        OpportunityUtils.ProcessBigDeals(opps);
        Test.stopTest();

        Assert.isNull(opps[0].Highlights__c, 
                      'Opportunity amount of null should not populate big deal message');
    }

}
