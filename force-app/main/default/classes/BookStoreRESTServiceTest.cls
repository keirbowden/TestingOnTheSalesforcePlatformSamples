@isTest
private class BookStoreRESTServiceTest {

    // GET REST Method Tests
    @isTest
    static void TestGetBooksByAuthorValidAuthorAndBooks(){
        List<Author__c> authors = new List<Author__c>();
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Keir Bowden', null));
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Bob Buzzard', null));
        insert authors;

        List<Book__c> books = new List<Book__c>();
        books.add(FullBookStoreTestDataFactory.BuildBook('Swords and SOQL', authors[0].Id, 
                                                         'Fantasy', 190, null, System.today()));      
        books.add(FullBookStoreTestDataFactory.BuildBook('Lightning Web Components', authors[0].Id, 
                                                         'Technology', 176, null, System.today().addDays(-30)));
        books.add(FullBookStoreTestDataFactory.BuildBook('Flow for Dummies', authors[1].Id, 
                                                         'Technology', 50, null, System.today()));
        insert books;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/bookstore/getBooksByAuthor/';
        req.httpMethod = 'GET';
        req.params.put('authorName', 'Keir Bowden');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        List<BookStoreRESTService.BookDTO> booksByAuthor=BookStoreRESTService.getBooksByAuthor();
        Test.stopTest();

        Assert.areEqual(2, booksByAuthor.size(), 
                            'The test data contains 2 books by Keir Bowden');

        for (BookStoreRESTService.BookDTO bookDTO : booksByAuthor)  {
            if (bookDTO.title == 'Swords and SOQL') { 
                Assert.areEqual(books[0].Id, bookDTO.id, 
                                'Expected the checked book to match Swords and SOQL ID');
                Assert.areEqual('Fantasy', bookDTO.genre, 
                                'Expected the checked book to match Swords and SOQL genre');
                Assert.areEqual(books[0].Published_Date__c, bookDTO.publishedDate, 
                                'Expected the checked book to match Swords and SOQL published date');
                Assert.areEqual(books[0].Pages__c, bookDTO.pages, 
                                'Expected the checked book to match Swords and SOQL page count');
            }
        }
    }

    // POST REST Method Tests
    @isTest
    static void TestGetBooksByAuthorValidAuthorNoBooks(){
        List<Author__c> authors = new List<Author__c>();
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Keir Bowden', null));
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Bob Buzzard', null));
        insert authors;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/bookstore/getBooksByAuthor/';
        req.httpMethod = 'GET';
        req.params.put('authorName', 'Keir Bowden');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        List<BookStoreRESTService.BookDTO> booksByAuthor=BookStoreRESTService.getBooksByAuthor();
        Test.stopTest();

        Assert.areEqual(0, booksByAuthor.size(), 
                        'Expected zero length book list to be returned for a valid author with no books');
    }

    @isTest
    static void TestGetBooksByAuthorNullAuthorName(){
        List<Author__c> authors = new List<Author__c>();
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Keir Bowden', null));
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Bob Buzzard', null));
        insert authors;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/bookstore/getBooksByAuthor/';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        List<BookStoreRESTService.BookDTO> booksByAuthor=BookStoreRESTService.getBooksByAuthor();
        Test.stopTest();

        Assert.areEqual(0, booksByAuthor.size(), 
                        'Expected zero length book list to be returned for a null author name');

        Assert.areEqual(400, res.statusCode, 
                        'Expected a 400 status code for a null author name');
    }

    @isTest
    static void TestGetBooksByAuthorEmptyAuthorName(){
        List<Author__c> authors = new List<Author__c>();
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Keir Bowden', null));
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Bob Buzzard', null));
        insert authors;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/bookstore/getBooksByAuthor/';
        req.httpMethod = 'GET';
        req.params.put('authorName', '');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        List<BookStoreRESTService.BookDTO> booksByAuthor=BookStoreRESTService.getBooksByAuthor();
        Test.stopTest();

        Assert.areEqual(0, booksByAuthor.size(), 
                        'Expected zero length book list to be returned for an empty author name');

        Assert.areEqual(400, res.statusCode, 
                        'Expected a 400 status code for an empty author name');
    }

    @isTest
    static void TestCreateAuthorAndBooksOneBook() {
        BookStoreRestService.CreateAuthorAndBooksRequest requestData=
                    new BookStoreRestService.CreateAuthorAndBooksRequest();

        requestData.name='Keir Bowden';
        requestData.emailAddress='keir.bowden@googlemail.com';
        BookStoreRestService.BookDTO book=
                new BookStoreRestService.BookDTO(null,
                            'Swords and SOQL', 'Fantasy', System.today(), 190, null, null);
        requestData.books=new List<BookStoreRestService.BookDTO>{book};

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();   

        req.requestURI = '/services/apexrest/bookstore/authorWithBooks';
        req.httpMethod = 'POST';    
        req.requestBody = Blob.valueOf(JSON.serialize(requestData));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        BookStoreRestService.CreateAuthorAndBooksResponse response=BookStoreRestService.createAuthorWithBooks();
        Test.stopTest();

        Assert.areEqual(201, res.statusCode,
                        'Expected the success status code');

        Assert.areEqual(true, response.success,
                        'Expected the author and book to be created successfully');

        List<Author__c> authorsFromDB=[select id, Name, Email_Address__c,
                                           (select id, Name, Genre__c, Published_Date__c, Pages__c
                                            from Books__r)
                                       from Author__c];

        Assert.areEqual(1, authorsFromDB.size(), 
                        'Expected one author record to be created in the database');

        Author__c authorFromDB=authorsFromDB[0];

        Assert.areEqual(authorFromDB.Id, response.authorId,
                        'Expected the author id to be returned');

        Assert.areEqual(1, response.bookIds.size(),
                        'Expected one book to be returned');

        Assert.areEqual(requestData.name, authorFromDB.Name,
                        'Expected the author name to be correctly populated in the database');

        Assert.areEqual(requestData.emailAddress, authorFromDB.Email_Address__c,
                        'Expected the author email address to be correctly populated in the database');

        Assert.areEqual(1, authorFromDB.Books__r.size(),
                        'Expected one book record to be created in the database');
        

        Book__c bookFromDB=authorFromDB.Books__r[0];
        Assert.areEqual(bookFromDB.Id, response.bookIds[0],
                        'Expected the book id to be returned');

        Assert.areEqual(book.title, bookFromDB.Name,
                        'Expected the book title to be correctly populated in the database');

        Assert.areEqual(book.genre, bookFromDB.Genre__c,
                        'Expected the book genre to be correctly populated in the database');

        Assert.areEqual(book.publishedDate, bookFromDB.Published_Date__c,
                        'Expected the book published date to be correctly populated in the database');

        Assert.areEqual(book.pages, bookFromDB.Pages__c,
                        'Expected the book page count to be correctly populated in the database');
    }

    @isTest
    static void TestCreateAuthorAndBooksMultipleBooks() {
        BookStoreRestService.CreateAuthorAndBooksRequest requestData=
                    new BookStoreRestService.CreateAuthorAndBooksRequest();

        requestData.name='Keir Bowden';
        requestData.emailAddress='keir.bowden@googlemail.com';
        requestData.books=new List<BookStoreRestService.BookDTO>();
        requestData.books.add(new BookStoreRestService.BookDTO(null,
                            'Swords and SOQL', 'Fantasy', System.today(), 190, null, null));

        requestData.books.add(new BookStoreRestService.BookDTO(null,
                            'Testing on the Salesforce Platform', 'Technology', System.today().addDays(10), 15, null, null));

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();   

        req.requestURI = '/services/apexrest/bookstore/authorWithBooks';
        req.httpMethod = 'POST';    
        req.requestBody = Blob.valueOf(JSON.serialize(requestData));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        BookStoreRestService.CreateAuthorAndBooksResponse response=BookStoreRestService.createAuthorWithBooks();
        Test.stopTest();

        Assert.areEqual(true, response.success,
                        'Expected the author and book to be created successfully');

        Assert.areEqual(2, response.bookIds.size(),
                        'Expected two books to be returned');

        Author__c authorFromDB=[select id, Name, Email_Address__c,
                                     (select id, Name, Genre__c, Published_Date__c, Pages__c
                                      from Books__r)
                                 from Author__c];

        Assert.areEqual(2, authorFromDB.Books__r.size(),
                        'Expected two book records to be created in the database');
    }

    @isTest
    static void TestCreateAuthorAndBooksRequestNull() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();   

        req.requestURI = '/services/apexrest/bookstore/authorWithBooks';
        req.httpMethod = 'POST';    
        req.requestBody = null;

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        BookStoreRestService.CreateAuthorAndBooksResponse response=BookStoreRestService.createAuthorWithBooks();
        Test.stopTest();

        Assert.areEqual(false, response.success,
                        'Expected null request to fail');

        Assert.areEqual(500, res.statusCode,
                        'Expected the error status code');
    }

    @isTest
    static void TestCreateAuthorAndBooksAuthorNameNull() {
        BookStoreRestService.CreateAuthorAndBooksRequest requestData=
                    new BookStoreRestService.CreateAuthorAndBooksRequest();

        requestData.name=null;
        requestData.emailAddress='keir.bowden@googlemail.com';
        requestData.books=new List<BookStoreRestService.BookDTO>();
        requestData.books.add(new BookStoreRestService.BookDTO(null,
                            'Swords and SOQL', 'Fantasy', System.today(), 190, null, null));

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();   

        req.requestURI = '/services/apexrest/bookstore/authorWithBooks';
        req.httpMethod = 'POST';    
        req.requestBody = Blob.valueOf(JSON.serialize(requestData));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        BookStoreRestService.CreateAuthorAndBooksResponse response=BookStoreRestService.createAuthorWithBooks();
        Test.stopTest();

        Assert.areEqual(false, response.success,
                        'Expected request with empty string author name to fail');

        Assert.areEqual(400, res.statusCode,
                        'Expected the error status code');

        List<Author__c> authorsFromDB=[select id, Name, Email_Address__c,
                                          (select id, Name, Genre__c, Published_Date__c, Pages__c
                                           from Books__r)
                                       from Author__c];

        Assert.areEqual(0, authorsFromDB.size(),
                        'Expected no author records to be created in the database');    
    }

    @isTest
    static void TestCreateAuthorAndBooksAuthorNameEmptyString() {
        BookStoreRestService.CreateAuthorAndBooksRequest requestData=
                    new BookStoreRestService.CreateAuthorAndBooksRequest();

        requestData.name='';
        requestData.emailAddress='keir.bowden@googlemail.com';
        requestData.books=new List<BookStoreRestService.BookDTO>();
        requestData.books.add(new BookStoreRestService.BookDTO(null,
                            'Swords and SOQL', 'Fantasy', System.today(), 190, null, null));

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();   

        req.requestURI = '/services/apexrest/bookstore/authorWithBooks';
        req.httpMethod = 'POST';    
        req.requestBody = Blob.valueOf(JSON.serialize(requestData));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        BookStoreRestService.CreateAuthorAndBooksResponse response=BookStoreRestService.createAuthorWithBooks();
        Test.stopTest();

        Assert.areEqual(false, response.success,
                        'Expected request with null author name to fail');

        Assert.areEqual(400, res.statusCode,
                        'Expected the error status code');

        List<Author__c> authorsFromDB=[select id, Name, Email_Address__c,
                                          (select id, Name, Genre__c, Published_Date__c, Pages__c
                                           from Books__r)
                                       from Author__c];

        Assert.areEqual(0, authorsFromDB.size(),
                        'Expected no author records to be created in the database');        
    }

    @isTest
    static void TestCreateAuthorAndBooksNullBooks() {
        BookStoreRestService.CreateAuthorAndBooksRequest requestData=
                    new BookStoreRestService.CreateAuthorAndBooksRequest();

        requestData.name='Keir Bowden';
        requestData.emailAddress='keir.bowden@googlemail.com';
        requestData.books=null;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();   

        req.requestURI = '/services/apexrest/bookstore/authorWithBooks';
        req.httpMethod = 'POST';    
        req.requestBody = Blob.valueOf(JSON.serialize(requestData));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        BookStoreRestService.CreateAuthorAndBooksResponse response=BookStoreRestService.createAuthorWithBooks();
        Test.stopTest();

        Assert.areEqual(false, response.success,
                        'Expected request with null book list to fail');

        Assert.areEqual(400, res.statusCode,
                        'Expected the error status code');

        List<Author__c> authorsFromDB=[select id, Name, Email_Address__c,
                                          (select id, Name, Genre__c, Published_Date__c, Pages__c
                                           from Books__r)
                                       from Author__c];

        Assert.areEqual(0, authorsFromDB.size(),
                        'Expected no author records to be created in the database');    
    }

    @isTest
    static void TestCreateAuthorAndBooksZeroBooks() {
        BookStoreRestService.CreateAuthorAndBooksRequest requestData=
                    new BookStoreRestService.CreateAuthorAndBooksRequest();

        requestData.name='Keir Bowden';
        requestData.emailAddress='keir.bowden@googlemail.com';
        requestData.books=new List<BookStoreRestService.BookDTO>();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();   

        req.requestURI = '/services/apexrest/bookstore/authorWithBooks';
        req.httpMethod = 'POST';    
        req.requestBody = Blob.valueOf(JSON.serialize(requestData));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        BookStoreRestService.CreateAuthorAndBooksResponse response=BookStoreRestService.createAuthorWithBooks();
        Test.stopTest();

        Assert.areEqual(false, response.success,
                        'Expected request with empty book list to fail');

        Assert.areEqual(400, res.statusCode,
                        'Expected the error status code');

        List<Author__c> authorsFromDB=[select id, Name, Email_Address__c,
                                          (select id, Name, Genre__c, Published_Date__c, Pages__c
                                           from Books__r)
                                       from Author__c];

        Assert.areEqual(0, authorsFromDB.size(),
                        'Expected no author records to be created in the database');  
    }

    @isTest
    static void TestCreateAuthorAndBooksHandleInternalError() {
        BookStoreRestService.CreateAuthorAndBooksRequest requestData=
                    new BookStoreRestService.CreateAuthorAndBooksRequest();

        requestData.name='Keir Bowden';
        requestData.emailAddress='keir.bowden@googlemail.com';
        requestData.books=new List<BookStoreRestService.BookDTO>();
        requestData.books.add(new BookStoreRestService.BookDTO(null,
                            'Swords and SOQL', 'Fantasy', System.today(), 190, null, null));

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();   

        req.requestURI = '/services/apexrest/bookstore/authorWithBooks';
        req.httpMethod = 'POST';    
        req.requestBody = Blob.valueOf(JSON.serialize(requestData));

        RestContext.request = req;
        RestContext.response = res;

        BookStoreDAOStubThrowError stub=new BookStoreDAOStubThrowError();
        BookStoreRESTService.storeDAO=stub;

        Test.startTest();
        BookStoreRestService.CreateAuthorAndBooksResponse response=BookStoreRestService.createAuthorWithBooks();
        Test.stopTest();

        Assert.areEqual(false, response.success,
                        'Expected request with empty book list to fail');

        Assert.areEqual(500, res.statusCode,
                        'Expected the error status code');

        List<Author__c> authorsFromDB=[select id, Name, Email_Address__c,
                                          (select id, Name, Genre__c, Published_Date__c, Pages__c
                                           from Books__r)
                                       from Author__c];

        Assert.areEqual(0, authorsFromDB.size(),
                        'Expected no author records to be created in the database');  
    }
}