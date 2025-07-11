@IsTest
private class SalesRepTest {
    @IsTest
    static void TestSalesRepUpdateOpportunityStage() {
        Profile salesRepProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User salesRepUser = new User(
            FirstName = 'Test', LastName = 'SalesRep',
            Email = 'test.salesrep@example.com',
            Username = 'test.salesrep.' + System.currentTimeMillis() + '@example.com',
            Alias = 'tsrep', TimeZoneSidKey = 'Europe/London',
            LocaleSidKey = 'en_GB', EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US', ProfileId = salesRepProfile.Id
        );

        insert salesRepUser;    

        Opportunity opp = new Opportunity(Name='Test Opp', Amount=250000,
                                            CloseDate=System.today().addDays(20),
                                            StageName='Prospecting',
                                            OwnerId=salesRepUser.Id);
        insert opp;

        System.runAs(salesRepUser) {
            opp.StageName = 'Negotiation';
            update opp;
        }

        Opportunity updated = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Negotiation', updated.StageName, 'Sales Rep should be able to update stage');
    }
}