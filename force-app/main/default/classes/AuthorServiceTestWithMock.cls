@IsTest
private class AuthorServiceTestWithMock {
    @IsTest
    static void TestScheduleReadingDefaultVirtualReading() {
        Book__c book=BookStoreTestDataFactory.BuildBook('Testing on the Salesforce Platform',
                                        null, 'Technology', 190);
        book.Id='a03JW00000oZqxvYAC';

        DateTime startDT=System.now().addHours(72);
        DateTime endDT=System.now().addHours(73);

        BookStoreDAOAuthorReadingMock storeDAOMock=new BookStoreDAOAuthorReadingMock();

        Author_Reading__c reading=new Author_Reading__c(Book__c=book.Id,
                                                        Starts__c=startDT,
                                                        Ends__c=endDT,
                                                        Virtual__c=false);
        storeDAOMock.expectedAuthorReadingCount=1;
        storeDAOMock.expectedReadings=new List<Author_Reading__c>{reading};

        Task task=new Task(ActivityDate=endDT.date().addDays(-1));        
        storeDAOMock.expectedTaskCount=1;
        storeDAOMock.expectedTasks=new List<Task>{task};

        AuthorService authorService=new AuthorService();
        authorService.storeDAO=storeDAOMock;

        Test.startTest();
        authorService.scheduleReading(book, startDT, endDT, null);
        Test.stopTest();

        List<String> errors=storeDAOMock.verify();
        if (!errors.isEmpty()) {
            String failMsg='Mock verification failed with the following errors:\n';
            for (String error : errors) {
                failMsg+=error+'\n';
            }
            Assert.fail(failMsg);
        }
    }

    @IsTest
    static void TestScheduleReadingVirtual() {
        Book__c book=BookStoreTestDataFactory.BuildBook('Testing on the Salesforce Platform',
                                        null, 'Technology', 190);

        DateTime startDT=System.now().addHours(24);
        DateTime endDT=System.now().addHours(25);

        BookStoreDAOAuthorReadingMock storeDAOMock=new BookStoreDAOAuthorReadingMock();

        Author_Reading__c reading=new Author_Reading__c(Book__c=book.Id,
                                                        Starts__c=startDT,
                                                        Ends__c=endDT,
                                                        Virtual__c=true);
        storeDAOMock.expectedAuthorReadingCount=1;
        storeDAOMock.expectedReadings=new List<Author_Reading__c>{reading};

        Event event=new Event(StartDateTime=startDT,
                              EndDateTime=endDT,
                              Location='Online');        
        storeDAOMock.expectedEventCount=1;
        storeDAOMock.expectedEvents=new List<Event>{event};

        AuthorService authorService=new AuthorService();
        authorService.storeDAO=storeDAOMock;

        Test.startTest();
        authorService.scheduleReading(book, startDT, endDT, true);
        Test.stopTest();

        List<String> errors=storeDAOMock.verify();
        if (!errors.isEmpty()) {
            String failMsg='Mock verification failed with the following errors:\n';
            for (String error : errors) {
                failMsg+=error+'\n';
            }
            Assert.fail(failMsg);
        }
    }

    @IsTest
    static void TestScheduleReadingNotVirtual() {
        Book__c book=BookStoreTestDataFactory.BuildBook('Testing on the Salesforce Platform',
                                        null, 'Technology', 190);

        DateTime startDT=System.now().addHours(24);
        DateTime endDT=System.now().addHours(25);

        BookStoreDAOAuthorReadingMock storeDAOMock=new BookStoreDAOAuthorReadingMock();

        Author_Reading__c reading=new Author_Reading__c(Book__c=book.Id,
                                                        Starts__c=startDT,
                                                        Ends__c=endDT,
                                                        Virtual__c=false);
        storeDAOMock.expectedAuthorReadingCount=1;
        storeDAOMock.expectedReadings=new List<Author_Reading__c>{reading};

        storeDAOMock.expectedEventCount=0;

        AuthorService authorService=new AuthorService();
        authorService.storeDAO=storeDAOMock;

        Test.startTest();
        authorService.scheduleReading(book, startDT, endDT, false);
        Test.stopTest();

        List<String> errors=storeDAOMock.verify();
        if (!errors.isEmpty()) {
            String failMsg='Mock verification failed with the following errors:\n';
            for (String error : errors) {
                failMsg+=error+'\n';
            }
            Assert.fail(failMsg);
        }
    }
}