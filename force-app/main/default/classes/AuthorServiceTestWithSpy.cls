@IsTest
private class AuthorServiceTestWithSpy {
    @IsTest 
    static void TestPublishBook() {
        Publisher__c publisher=BookStoreTestDataFactory.BuildPublisher('Leanpub');
        Author__c author=BookStoreTestDataFactory.BuildAuthor('Keir Bowden', publisher.Id);
        Book__c book=BookStoreTestDataFactory.BuildBook('Testing on the Salesforce Platform',
                                        author.Id, 'Technology', 190);

        AuthorService authorService=new AuthorService();
        BookStoreDAOUpdateBooksSpy spy=new BookStoreDAOUpdateBooksSpy();
        authorService.storeDAO=spy;
                                
        Test.startTest();
        authorService.publishBooks(author, new List<Book__c> {book});
        Test.stopTest();

        Assert.areEqual(1, spy.updateBooksHistory.size(),
                'Update books should be called once');

        Assert.areEqual(1, spy.updateBooksHistory[0].books.size(),
                'Update books should be called with a single book record');

        Assert.areEqual(book, spy.updateBooksHistory[0].books[0],
                'Update books should be called with the test book');
    }

    @IsTest 
    static void TestPublishBooksNullBook() {
        Publisher__c publisher=BookStoreTestDataFactory.BuildPublisher('Leanpub');
        Author__c author=BookStoreTestDataFactory.BuildAuthor('Keir Bowden', publisher.Id);

        List<Book__c> books=new List<Book__c>();

        books.add(BookStoreTestDataFactory.BuildBook('Testing on the Salesforce Platform',
                                        author.Id, 'Technology', 190));

        books.add(BookStoreTestDataFactory.BuildBook('The Wizard and the Admin',
                                        author.Id, 'Fantasy', 75));

        books.add(1, null);

        AuthorService authorService=new AuthorService();
        BookStoreDAOUpdateBooksSpy spy=new BookStoreDAOUpdateBooksSpy();
        authorService.storeDAO=spy;

        Test.startTest();
        authorService.publishBooks(author, books);
        Test.stopTest();

        Assert.areEqual(1, spy.updateBooksHistory.size(),
                'Update books should be called once');

        Assert.areEqual(2, spy.updateBooksHistory[0].books.size(),
                'Update books should be called with a two book records');

        Assert.areEqual(books[0], spy.updateBooksHistory[0].books[0],
                'First book updated should be technology book');

        Assert.areEqual(books[2], spy.updateBooksHistory[0].books[1],
                'Second book updated should be fantasy book');
    }

    @IsTest 
    static void TestPublishBooks200Records() {
        Publisher__c publisher=BookStoreTestDataFactory.BuildPublisher('Leanpub');
        Author__c author=BookStoreTestDataFactory.BuildAuthor('Keir Bowden', publisher.Id);

        List<Book__c> books=new List<Book__c>();

        Integer bookCount=200;
        for (Integer idx=0; idx<bookCount; idx++) {
            books.add(BookStoreTestDataFactory.BuildBook('Test Book ' + idx,
                                        author.Id, 'Technology', 190+idx));
        }

        AuthorService authorService=new AuthorService();
        BookStoreDAOUpdateBooksSpy spy=new BookStoreDAOUpdateBooksSpy();
        authorService.storeDAO=spy;

        Test.startTest();
        authorService.publishBooks(author, books);
        Test.stopTest();

        List<Book__c> booksFromDB=[select id, Published_Date__c 
                                   from Book__c
                                   where Published_Date__c=:System.today()];

        Assert.areEqual(1, spy.updateBooksHistory.size(),
                'Update books should be called once');

        Assert.areEqual(200, spy.updateBooksHistory[0].books.size(),
                'Update books should be called with 200 book records');

        Assert.areEqual(books, spy.updateBooksHistory[0].books,
                'Update books should be called with the test book collection');

    }
    
    @IsTest 
    static void TestPublishBooksScope() {
        Publisher__c publisher=BookStoreTestDataFactory.CreatePublisher('Leanpub');
        Author__c author=BookStoreTestDataFactory.CreateAuthor('Keir Bowden', publisher.Id);

        List<Book__c> books=new List<Book__c>();

        books.add(BookStoreTestDataFactory.BuildBook('Testing on the Salesforce Platform',
                                        author.Id, 'Technology', 190));

        books.add(BookStoreTestDataFactory.BuildBook('The Wizard and the Admin',
                                        author.Id, 'Fantasy', 75));

        insert books;

        AuthorService authorService=new AuthorService();
        BookStoreDAOUpdateBooksSpy spy=new BookStoreDAOUpdateBooksSpy();
        authorService.storeDAO=spy;

        Test.startTest();
        authorService.publishBooks(author, new List<Book__c> {books[0]});
        Test.stopTest();

         Assert.areEqual(1, spy.updateBooksHistory.size(),
                'Update books should be called once');

        Assert.areEqual(1, spy.updateBooksHistory[0].books.size(),
                'Update books should be called with a single book record');

        Assert.areEqual(books[0], spy.updateBooksHistory[0].books[0],
                'Update books should be called with the test book');
   }
}