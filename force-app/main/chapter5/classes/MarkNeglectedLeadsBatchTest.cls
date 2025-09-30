@isTest
private class MarkNeglectedLeadsBatchTest {
    @IsTest
	static void TestNewLeadBelowThresholdNotNeglected() {
        List<Lead> leads=LeadTestDataFactory.createLeads(1);
        insert leads;

	    Test.startTest();
		Database.executeBatch(new MarkNeglectedLeadsBatch());
		Test.stopTest();
		
		List<Lead> leadsFromDB=[select id, Status from Lead];
		
		System.assertEquals(1, leadsFromDB.size());
		System.assertEquals(MarkNeglectedLeadsBatch.NEW_STATUS, 
								leadsFromDB[0].Status);
	}

    @IsTest
	static void TestNewLeadAtThresholdNotNeglected() {
        List<Lead> leads=LeadTestDataFactory.createLeads(1);
        insert leads;

    	DateTime testCreatedDT=System.now().addDays(-5);
    	Test.setCreatedDate(leads[0].id, testCreatedDT);

	    Test.startTest();
		Database.executeBatch(new MarkNeglectedLeadsBatch());
		Test.stopTest();
		
		List<Lead> leadsFromDB=[select id, Status from Lead];
		
		System.assertEquals(1, leadsFromDB.size());
		System.assertEquals(MarkNeglectedLeadsBatch.NEW_STATUS, 
								leadsFromDB[0].Status);
	}

	@IsTest
	static void TestNewLeadOverThreasholdIsNeglected() {
        List<Lead> leads=LeadTestDataFactory.createLeads(1);
        insert leads;

    	DateTime testCreatedDT=System.now().addDays(-5).addHours(-2);
    	Test.setCreatedDate(leads[0].id, testCreatedDT);

	    Test.startTest();
		Database.executeBatch(new MarkNeglectedLeadsBatch());
		Test.stopTest();
		
		List<Lead> leadsFromDB=[select id, Status from Lead];
		
		System.assertEquals(1, leadsFromDB.size());
		System.assertEquals(LeadUtils.STALE_STATUS, 
								leadsFromDB[0].Status);
	}

    @IsTest
	static void TestAlreadyStaleLeadUnchanged() {
        List<Lead> leads=LeadTestDataFactory.createLeads(1);
        leads[0].Status=LeadUtils.STALE_STATUS;
        insert leads;
    	
		DateTime createdDT=System.now().addDays(-5).addHours(-2);
    	
		Test.setCreatedDate(leads[0].id, createdDT);

		Test.startTest();
		Database.executeBatch(new MarkNeglectedLeadsBatch());
		Test.stopTest();
		
		List<Lead> leadsFromDB=[select id, Status from Lead];
		
		System.assertEquals(1, leadsFromDB.size());
		System.assertEquals(LeadUtils.STALE_STATUS, 
								leadsFromDB[0].Status);
	}

	@IsTest
	static void TestBulkNeglectedLeads() {
        Integer scopeSize=300;
        List<Lead> leads=LeadTestDataFactory.createLeads(scopeSize);
        insert leads;

        for (Integer idx=0; idx<scopeSize; idx++) {
    	    DateTime testCreatedDT=System.now().addDays(-5).addHours(-1*(idx+2));
        	Test.setCreatedDate(leads[idx].id, testCreatedDT);
        }

	    Test.startTest();
		Database.executeBatch(new MarkNeglectedLeadsBatch(), scopeSize);
		Test.stopTest();
		
		List<Lead> leadsFromDB=[select id, Status 
                                from Lead
                                where status=:LeadUtils.STALE_STATUS];
		
		System.assertEquals(scopeSize, leadsFromDB.size());
	}
}