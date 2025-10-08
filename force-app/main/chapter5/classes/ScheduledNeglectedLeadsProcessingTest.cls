@isTest
private class ScheduledNeglectedLeadsProcessingTest {
    static String GetFutureCronStr() {
        Integer nextYear=System.today().year()+1;
        return '0 0 0 11 6 ? ' + nextYear;
    }

    @isTest
    static void TestScheduleDefaultBatchSize() {
	    Test.startTest();
		System.schedule('ScheduledNeglectedLeadsProcessingTest',  GetFutureCronStr(),
                            new ScheduledNeglectedLeadsProcessing());
		Test.stopTest();
		
        List<AsyncApexJob> asyncJobs = [
                    select JobType
                    from AsyncApexJob
                    where JobType='BatchApex'
                      and ApexClass.Name='MarkNeglectedLeadsBatch'];

        Assert.areEqual(1, asyncJobs.size(),
                        'Batch job should be enqueued');
	} 

    @isTest
    static void TestScheduleBatchSizeMin() {
	    Test.startTest();
		System.schedule('ScheduledNeglectedLeadsProcessingTest',  GetFutureCronStr(),
                            new ScheduledNeglectedLeadsProcessing(1));
		Test.stopTest();
		
        List<AsyncApexJob> asyncJobs = [
                    select JobType
                    from AsyncApexJob
                    where JobType='BatchApex'
                      and ApexClass.Name='MarkNeglectedLeadsBatch'];

        Assert.areEqual(1, asyncJobs.size(),
                        'Batch job should be enqueued for scope size of 1');
	} 

    @isTest
    static void TestScheduleBatchSizeMax() {
	    Test.startTest();
		System.schedule('ScheduledNeglectedLeadsProcessingTest',  GetFutureCronStr(),
                            new ScheduledNeglectedLeadsProcessing(2000));
		Test.stopTest();
		
        List<AsyncApexJob> asyncJobs = [
                    select JobType
                    from AsyncApexJob
                    where JobType='BatchApex'
                      and ApexClass.Name='MarkNeglectedLeadsBatch'];

        Assert.areEqual(1, asyncJobs.size(),
                        'Batch job should be enqueued for scope size of 2000');
	} 

    @isTest
    static void TestScheduleBatchSizeTooSmall() {
	    Test.startTest();
        try {
		    System.schedule('ScheduledNeglectedLeadsProcessingTest',  GetFutureCronStr(),
                                new ScheduledNeglectedLeadsProcessing(0));
            Assert.fail('Constructing scheduled class with  scope size of 0 should throw exception');
        }
        catch (NeglectedLeadsException nle) {
            // expected
        }
		Test.stopTest();
	} 

    @isTest
    static void TestScheduleBatchSizeTooLarge() {
	    Test.startTest();
        try {
		    System.schedule('ScheduledNeglectedLeadsProcessingTest',  GetFutureCronStr(),
                                new ScheduledNeglectedLeadsProcessing(2001));
            Assert.fail('Constructing scheduled class with scope size of 2001 should throw exception');
        }
        catch (NeglectedLeadsException nle) {
            // expected
        }
		Test.stopTest();		
	} 

    @isTest
    static void TestScheduleBatchSizeNull() {
	    Test.startTest();
        try {
		    System.schedule('ScheduledNeglectedLeadsProcessingTest',  GetFutureCronStr(),
                                new ScheduledNeglectedLeadsProcessing(null));
            Assert.fail('Constructing scheduled class with null batch size should throw exception');
        }
        catch (NeglectedLeadsException nle) {
            // expected
        }
		Test.stopTest();		
	} 
}