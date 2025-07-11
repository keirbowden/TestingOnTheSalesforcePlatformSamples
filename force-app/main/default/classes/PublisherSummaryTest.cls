@IsTest
private class PublisherSummaryTest {
    /* Test case 1 - Top-rated author record is detected */
    @isTest
    static void TestTopRatedAuthorCountNonZero() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Leanpub');

        List<Author__c> authors=new List<Author__c>();
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Keir Bowden', publisher.Id, '5'));
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Bob Buzzard', publisher.Id, '2'));
        insert authors;

        List<Book__c> books=new List<Book__c>();
        books.add(FullBookStoreTestDataFactory.BuildBook('Swords and SOQL', authors[0].Id, 
                                                         'Fantasy', 190, publisher.Id, System.today()));
        books.add(FullBookStoreTestDataFactory.BuildBook('Flow for Dummies', authors[1].Id, 
                                                         'Technology', 50, publisher.Id, System.today()));
        insert books;

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        Test.startTest();
        pubSum.collectAuthorDetail();
        Test.stopTest();

        Assert.areEqual(1, pubSum.getTopRatedAuthorCount(), 'Expected to find one top rated author');
    }

    /* Test Case 2 - Lack of top-rated author record is detected */
    @isTest
    static void TestTopRatedAuthorCountZero() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Leanpub');

        List<Author__c> authors=new List<Author__c>();
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Keir Bowden', publisher.Id, '1'));
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Bob Buzzard', publisher.Id, '2'));
        insert authors;

        List<Book__c> books=new List<Book__c>();
        books.add(FullBookStoreTestDataFactory.BuildBook('Swords and SOQL', authors[0].Id, 
                                                         'Fantasy', 190, publisher.Id, System.today()));
        books.add(FullBookStoreTestDataFactory.BuildBook('Flow for Dummies', authors[1].Id, 
                                                         'Technology', 50, publisher.Id, System.today()));
        insert books;

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        Test.startTest();
        pubSum.collectAuthorDetail();
        Test.stopTest();

        Assert.areEqual(0, pubSum.getTopRatedAuthorCount(), 'Expected to find zero top rated author');
    }

    /* Test Case 3 - Last published date calculated from a single book */
    @isTest
    static void TestLastPublishedDateSingleBook() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Penguin');

        Author__c author=FullBookStoreTestDataFactory.CreateAuthor('Keir Bowden', publisher.Id, '3');

        Date publishDate=System.today().addMonths(-1);
        Book__c book=FullBookStoreTestDataFactory.CreateBook('Apex is Awesome!', author.Id, 
                                                         'Technology', 101, publisher.Id, publishDate);

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        Test.startTest();
        pubSum.collectBookDetail();
        Test.stopTest();

        Assert.areEqual(publishDate, pubSum.getLastPublishedDate(), 
                        'Expected last publish date to be ' + publishDate + 
                        ', but was ' + pubSum.getLastPublishedDate());
    }
   
    /* Test case 4 - Last published date calculated from multiple books */
    @isTest
    static void TestLastPublishedDateMultipleBooks() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Buzzard, Inc');

        List<Author__c> authors=new List<Author__c>();
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Darth Vader', publisher.Id, '1'));
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Luke Skywalker', publisher.Id, '2'));
        insert authors;

        Date lastPublishDate=System.today().addMonths(-1);

        List<Book__c> books=new List<Book__c>();
        books.add(FullBookStoreTestDataFactory.BuildBook('Building the Death Star', authors[0].Id, 
                                                         'Fantasy', 190, publisher.Id, lastPublishDate.addDays(10)));
        books.add(FullBookStoreTestDataFactory.BuildBook('Surviving Vader', authors[1].Id, 
                                                         'Fantasy', 200, publisher.Id, lastPublishDate));
        insert books;

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        Test.startTest();
        pubSum.collectBookDetail();
        Test.stopTest();

        Assert.areEqual(lastPublishDate, pubSum.getLastPublishedDate(), 
                        'Expected last publish date to be ' + lastPublishDate + 
                        ', but was ' + pubSum.getLastPublishedDate());
    }
 
    /*  Test Case 6 - getPublisher() executes a SOQL query if invoked before summarising */
    @isTest
    static void TestGetPublisherBeforeSummaryConsumesSOQL() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Buzzard, Inc');

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        Test.startTest();
        Publisher__c publisherFromSummary=pubSum.getPublisher();
        Integer soqlQueryCount=Limits.getQueries();
        Test.stopTest();

        Assert.isTrue(soqlQueryCount>0, 
                'Expected calling getPublisher() before summarising to consume SOQL queries');
    }
 
    /*  Test Case 6 - getPublisher() does not execute a SOQL query if invoked after summarising */
    @isTest
    static void TestGetPublisherAfterSummaryDoesNotConsumeSOQL() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Buzzard, Inc');

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);
        pubSum.getSummary();

        Test.startTest();
        Publisher__c publisherFromSummary=pubSum.getPublisher();
        Integer soqlQueryCount=Limits.getQueries();
        Test.stopTest();

        Assert.areEqual(0, soqlQueryCount, 
                'Expected calling getPublisher() after summarising to consume no SOQL queries');
    }    
    
    /*  Test Case 7 - Generate a summary with multiple books for a genre  */
    @isTest
    static void TestGetSummaryMultipleBooksGenre() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Bob Buzzard & Co');

        List<Author__c> authors=new List<Author__c>();
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Keir Bowden', publisher.Id, '1'));
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Bob Buzzard', publisher.Id, '2'));
        insert authors;

        List<Book__c> books=new List<Book__c>();
        books.add(FullBookStoreTestDataFactory.BuildBook('Lightning Web Components', authors[0].Id, 
                                                         'Technology', 176, publisher.Id, System.today().addDays(-30)));
        books.add(FullBookStoreTestDataFactory.BuildBook('Flow made Easy', authors[1].Id, 
                                                         'Technology', 75, publisher.Id, System.today().addDays(-20)));
        insert books;

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);
        pubSum.collectBookDetail();

        Test.startTest();
        String summary=pubSum.getSummary();
        Test.stopTest();

        Assert.isTrue(summary.contains('Technology - 2'),
                'Two books in the genre Technology should appear in the summary');
    }    
  
    /*  Test Case 8 - Generate a summary without collecting author details  */
    @isTest
    static void TestGetSummaryNoAuthorDetailsCollected() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Bob Buzzard & Co');

        Author__c author=FullBookStoreTestDataFactory.CreateAuthor('Keir Bowden', publisher.Id, '1');

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        Test.startTest();
        String summary=pubSum.getSummary();
        Test.stopTest();

        Assert.isFalse(summary.contains('author'),
                'Summary without collecting author details should not contain the word \'author\'');
    }    
      
    /*  Test Case 9 - Generate a summary after collecting author details  */
    @isTest
    static void TestGetSummaryWithAuthorDetailsCollected() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Bob Buzzard & Co');

        Author__c author=FullBookStoreTestDataFactory.CreateAuthor('Keir Bowden', publisher.Id, '1');

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);
        pubSum.collectAuthorDetail();

        Test.startTest();
        String summary=pubSum.getSummary();
        Test.stopTest();

        Assert.isTrue(summary.contains('author'),
                'Summary after collecting author details should contain the word \'author\'');
    }    
      
    /*  Test Case 10 - Summary without collecting book details doesn't include book values */
    @isTest
    static void TestGetSummaryNoBookDetails() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Bob Buzzard & Co');

        Author__c author=FullBookStoreTestDataFactory.CreateAuthor('Han Solo', publisher.Id, '1');

        List<Book__c> books=new List<Book__c>();
        books.add(FullBookStoreTestDataFactory.BuildBook('My Life as a Freebooter', author.Id, 
                                                         'Biography', 176, publisher.Id, System.today().addDays(-30)));
        books.add(FullBookStoreTestDataFactory.BuildBook('Moving on from the Death Star', author.Id, 
                                                         'Biography', 75, publisher.Id, System.today().addDays(-20)));
        insert books;

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        Test.startTest();
        String summary=pubSum.getSummary();
        Test.stopTest();

        Assert.isFalse(summary.contains('book'),
                'Summary without collecting book details should not contain the word \'book\'');
    }    

    /*  Test Case 11 - Calculate rating with books for every genre */
    @isTest
    static void TestCalcRatingBooksForAllGenres() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Bob Buzzard & Co');

        Author__c author=FullBookStoreTestDataFactory.CreateAuthor('Han Solo', publisher.Id, '5');

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        List<Book__c> books=new List<Book__c>();

        for (Schema.PicklistEntry genreEntry : Book__c.Genre__c.getDescribe().getPicklistValues()) {
            if (genreEntry.isActive()) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + genreEntry.label, 
                                                                 author.Id, 
                                                                 genreEntry.value, 
                                                                 176, 
                                                                 publisher.Id, 
                                                                 System.today()));
            }
        } 

        insert books;

        Test.startTest();
        Integer rating=pubSum.getPublisherRating();
        Test.stopTest();

        Assert.areEqual(100, rating,
                'Rating with a book for each genre (and everything else maxed out) should be 100');
    }      

    /*  Test Case 12 - Calculate rating with books for every genre bar one */
    @isTest
    static void TestCalcRatingBooksForAllGenresBarOne() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Bob Buzzard & Co');

        Author__c author=FullBookStoreTestDataFactory.CreateAuthor('Han Solo', publisher.Id, '5');

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        List<Book__c> books=new List<Book__c>();

        Boolean skippedGenre=false;
        for (Schema.PicklistEntry genreEntry : Book__c.Genre__c.getDescribe().getPicklistValues()) {
            if (genreEntry.isActive()) {
                if (skippedGenre) {
                    books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + genreEntry.label, 
                                                                 author.Id, 
                                                                 genreEntry.value, 
                                                                 176, 
                                                                 publisher.Id, 
                                                                 System.today()));
                }
                else {
                    skippedGenre=true;
                }
            }
        } 

        insert books;

        Test.startTest();
        Integer rating=pubSum.getPublisherRating();
        Test.stopTest();

        Assert.areEqual(98, rating,
                'Rating with a book for all genres bar one (and everything else maxed out) should be 98');
    }      

    /*  Test Case 13 - Calculate rating without books for multiple genres */
    @isTest
    static void TestCalcRatingBooksMissingForMultipleGenres() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Bob Buzzard & Co');

        Author__c author=FullBookStoreTestDataFactory.CreateAuthor('Han Solo', publisher.Id, '5');

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        List<Book__c> books=new List<Book__c>();

        Integer skippedGenres=0;
        for (Schema.PicklistEntry genreEntry : Book__c.Genre__c.getDescribe().getPicklistValues()) {
            if (genreEntry.isActive()) {
                if (3==skippedGenres) {
                    books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + genreEntry.label, 
                                                                 author.Id, 
                                                                 genreEntry.value, 
                                                                 176, 
                                                                 publisher.Id, 
                                                                 System.today()));
                }
                else {
                    skippedGenres++;
                }
            }
        } 

        insert books;

        Test.startTest();
        Integer rating=pubSum.getPublisherRating();
        Test.stopTest();

        Assert.areEqual(94, rating,
                'Rating with a book missing for three genres (and everything else maxed out) should be 94');
    }      

    /*  Test Case 14 - Calculate rating with average author rating of 1 */
    @isTest
    static void TestCalcRatingLowAuthorRating() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Buzzard Inc');

        Author__c author=FullBookStoreTestDataFactory.CreateAuthor('Lando Calrissian', publisher.Id, '1');

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        List<Book__c> books=new List<Book__c>();

        for (Schema.PicklistEntry genreEntry : Book__c.Genre__c.getDescribe().getPicklistValues()) {
            if (genreEntry.isActive()) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + genreEntry.label, 
                                                                 author.Id, 
                                                                 genreEntry.value, 
                                                                 176, 
                                                                 publisher.Id, 
                                                                 System.today()));
            }
        } 

        insert books;

        Test.startTest();
        Integer rating=pubSum.getPublisherRating();
        Test.stopTest();

        Assert.areEqual(1, pubSum.getAverageAuthorRating(), 
                       'A single author with a rating of 1 should result in a 1 average');
                         
        Assert.areEqual(70, rating,
                'Rating with low author rating (and everything else maxed out) should be 70');
    }          

    /*  Test Case 15 - Calculate rating with average author rating of 2 */
    @isTest
    static void TestCalcRatingOkayAuthorRating() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Buzzard Inc');

        List<Author__c> authors=new List<Author__c>();
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Lando Calrissian', publisher.Id, '1'));
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Bob Buzzard Jr', publisher.Id, '3'));
        authors.add(FullBookStoreTestDataFactory.BuildAuthor('Keir Bowden', publisher.Id, '2'));
        insert authors;

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        List<Book__c> books=new List<Book__c>();

        Integer bookCount=0;
        for (Schema.PicklistEntry genreEntry : Book__c.Genre__c.getDescribe().getPicklistValues()) {
            if (genreEntry.isActive()) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + genreEntry.label, 
                                                                 authors[Math.mod(bookCount++,3)].Id, 
                                                                 genreEntry.value, 
                                                                 176, 
                                                                 publisher.Id, 
                                                                 System.today()));
            }
        } 

        insert books;

        Test.startTest();
        Integer rating=pubSum.getPublisherRating();
        Test.stopTest();

        Assert.areEqual(2, pubSum.getAverageAuthorRating(), 
                       'Average author rating should be total 6 divided by 3 authors, = 2');
                         

        Assert.areEqual(90, rating,
                'Rating with okay author rating (and everything else maxed out) should be 90');
    }              

    /*  Test Case 16 - Calculate rating with top rated author count of 1 */
    @isTest
    static void TestCalcRatingTopRatedAuthors() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Buzzard Inc');

        Author__c author=FullBookStoreTestDataFactory.CreateAuthor('Lando Calrissian', publisher.Id, '5');

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        List<Book__c> books=new List<Book__c>();

        Integer bookCount=0;
        for (Schema.PicklistEntry genreEntry : Book__c.Genre__c.getDescribe().getPicklistValues()) {
            if (genreEntry.isActive()) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + genreEntry.label, 
                                                                 author.Id, 
                                                                 genreEntry.value, 
                                                                 176, 
                                                                 publisher.Id, 
                                                                 System.today()));
            }
        } 

        insert books;

        Test.startTest();
        Integer rating=pubSum.getPublisherRating();
        Test.stopTest();

        Assert.areEqual(100, rating,
                'Rating with top rated author and everything else maxed out should be 100');
    }    

    /*  Test Case 17 - First MC/DC tests of the complex condition in rating calcuation 
        Book count 30, Author Count 5, Last Published Date 4 months ago */
    @isTest
    static void TestCalcRatingMCDC1() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Buzzard Inc');

        List<Author__c> authors=new List<Author__c>();
        for (Integer idx=0; idx<5; idx++)
        {
            authors.add(FullBookStoreTestDataFactory.BuildAuthor('Test Author ' + idx, publisher.Id, 
                                                                ((idx+1).toString())));
        }
        insert authors;

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        Integer bookCount=0;
        List<Book__c> books=new List<Book__c>();
        for (Schema.PicklistEntry genreEntry : Book__c.Genre__c.getDescribe().getPicklistValues()) {
            if (genreEntry.isActive()) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + bookCount, 
                                                                 authors[Math.mod(bookCount++,5)].Id, 
                                                                 genreEntry.value, 
                                                                 176+bookCount, 
                                                                 publisher.Id, 
                                                                 System.today().addMonths(-4)));
            }
        } 

        while (bookCount<30) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + bookCount, 
                                                                 authors[Math.mod(bookCount++,5)].Id, 
                                                                 'Fantasy',
                                                                 176+bookCount, 
                                                                 publisher.Id, 
                                                                 System.today().addMonths(-4)));
        }

        insert books;

        Test.startTest();
        Integer rating=pubSum.getPublisherRating();
        Test.stopTest();

        Assert.areEqual(90, rating,
                'Rating with few authors and nothing recently published (everything else maxed) should be 90');
    }          

    /*  Test Case 18 - Second MC/DC tests of the complex condition in rating calcuation 
        Book count 30, Author Count 10, Last Published Date 4 months ago */
    @isTest
    static void TestCalcRatingMCDC2() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Buzzard Inc');

        List<Author__c> authors=new List<Author__c>();
        for (Integer idx=0; idx<10; idx++)
        {
            authors.add(FullBookStoreTestDataFactory.BuildAuthor('Test Author ' + idx, publisher.Id, 
                                                                ((Math.mod(idx, 5)+1).toString())));
        }
        insert authors;

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        Integer bookCount=0;
        List<Book__c> books=new List<Book__c>();
        for (Schema.PicklistEntry genreEntry : Book__c.Genre__c.getDescribe().getPicklistValues()) {
            if (genreEntry.isActive()) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + bookCount, 
                                                                 authors[Math.mod(bookCount++,10)].Id, 
                                                                 genreEntry.value, 
                                                                 176+bookCount, 
                                                                 publisher.Id, 
                                                                 System.today().addMonths(-4)));
            }
        } 

        while (bookCount<30) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + bookCount, 
                                                                 authors[Math.mod(bookCount++,10)].Id, 
                                                                 'Fantasy',
                                                                 176+bookCount, 
                                                                 publisher.Id, 
                                                                 System.today().addMonths(-4)));
        }

        insert books;

        Test.startTest();
        Integer rating=pubSum.getPublisherRating();
        Test.stopTest();

        Assert.areEqual(100, rating,
                'Rating with 10 authors but nothing recently published (everything else maxed) should be 100');
    }          

    /*  Test Case 19 - Third MC/DC tests of the complex condition in rating calcuation 
        Book count 30, Author Count 10, Last Published Date 2 months ago */
    @isTest
    static void TestCalcRatingMCDC3() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Buzzard Inc');

        List<Author__c> authors=new List<Author__c>();
        for (Integer idx=0; idx<10; idx++)
        {
            authors.add(FullBookStoreTestDataFactory.BuildAuthor('Test Author ' + idx, publisher.Id, 
                                                                ((Math.mod(idx, 5)+1).toString())));
        }
        insert authors;

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        Integer bookCount=0;
        List<Book__c> books=new List<Book__c>();
        for (Schema.PicklistEntry genreEntry : Book__c.Genre__c.getDescribe().getPicklistValues()) {
            if (genreEntry.isActive()) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + bookCount, 
                                                                 authors[Math.mod(bookCount++,10)].Id, 
                                                                 genreEntry.value, 
                                                                 176+bookCount, 
                                                                 publisher.Id, 
                                                                 System.today().addMonths(-2)));
            }
        } 

        while (bookCount<30) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + bookCount, 
                                                                 authors[Math.mod(bookCount++,10)].Id, 
                                                                 'Fantasy',
                                                                 176+bookCount, 
                                                                 publisher.Id, 
                                                                 System.today().addMonths(-2)));
        }

        insert books;

        Test.startTest();
        Integer rating=pubSum.getPublisherRating();
        Test.stopTest();

        Assert.areEqual(100, rating,
                'Rating with 10 authors and recently published (everything else maxed) should be 100');
    }          

    /*  Test Case 20 - Fourth MC/DC tests of the complex condition in rating calculation 
        Book count 10, Author Count 10, Last Published Date 7 months ago */
    @isTest
    static void TestCalcRatingMCDC4() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Buzzard Inc');

        List<Author__c> authors=new List<Author__c>();
        for (Integer idx=0; idx<10; idx++)
        {
            authors.add(FullBookStoreTestDataFactory.BuildAuthor('Test Author ' + idx, publisher.Id, 
                                                                ((Math.mod(idx, 5)+1).toString())));
        }
        insert authors;

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        Integer bookCount=0;
        List<Book__c> books=new List<Book__c>();
        for (Schema.PicklistEntry genreEntry : Book__c.Genre__c.getDescribe().getPicklistValues()) {
            if (genreEntry.isActive()) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + bookCount, 
                                                                 authors[Math.mod(bookCount++,10)].Id, 
                                                                 genreEntry.value, 
                                                                 176+bookCount, 
                                                                 publisher.Id, 
                                                                 System.today().addMonths(-7)));
            }
        } 

        while (bookCount<10) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + bookCount, 
                                                                 authors[Math.mod(bookCount++,10)].Id, 
                                                                 'Fantasy',
                                                                 176+bookCount, 
                                                                 publisher.Id, 
                                                                 System.today().addMonths(-7)));
        }

        insert books;

        Test.startTest();
        Integer rating=pubSum.getPublisherRating();
        Test.stopTest();

        Assert.areEqual(90, rating,
                'Rating with 10 books and not recently published (everything else maxed) should be 90');
    }          

    /*  Test Case 21 - Fifth MC/DC tests of the complex condition in rating calculation 
        Book count 25, Author Count 10, Last Published Date 7 months ago */
    @isTest
    static void TestCalcRatingMCDC5() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Buzzard Inc');

        List<Author__c> authors=new List<Author__c>();
        for (Integer idx=0; idx<10; idx++)
        {
            authors.add(FullBookStoreTestDataFactory.BuildAuthor('Test Author ' + idx, publisher.Id, 
                                                                ((Math.mod(idx, 5)+1).toString())));
        }
        insert authors;

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        Integer bookCount=0;
        List<Book__c> books=new List<Book__c>();
        for (Schema.PicklistEntry genreEntry : Book__c.Genre__c.getDescribe().getPicklistValues()) {
            if (genreEntry.isActive()) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + bookCount, 
                                                                 authors[Math.mod(bookCount++,10)].Id, 
                                                                 genreEntry.value, 
                                                                 176+bookCount, 
                                                                 publisher.Id, 
                                                                 System.today().addMonths(-7)));
            }
        } 

        while (bookCount<25) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + bookCount, 
                                                                 authors[Math.mod(bookCount++,10)].Id, 
                                                                 'Fantasy',
                                                                 176+bookCount, 
                                                                 publisher.Id, 
                                                                 System.today().addMonths(-7)));
        }

        insert books;

        Test.startTest();
        Integer rating=pubSum.getPublisherRating();
        Test.stopTest();

        Assert.areEqual(100, rating,
                'Rating with 25 books and not recently published (everything else maxed) should be 100');
    }          

    /*  Test Case 22 - Sixth MC/DC tests of the complex condition in rating calculation 
        Book count 10, Author Count 10, Last Published Date 5 months ago */
    @isTest
    static void TestCalcRatingMCDC6() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Buzzard Inc');

        List<Author__c> authors=new List<Author__c>();
        for (Integer idx=0; idx<10; idx++)
        {
            authors.add(FullBookStoreTestDataFactory.BuildAuthor('Test Author ' + idx, publisher.Id, 
                                                                ((Math.mod(idx, 5)+1).toString())));
        }
        insert authors;

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        Integer bookCount=0;
        List<Book__c> books=new List<Book__c>();
        for (Schema.PicklistEntry genreEntry : Book__c.Genre__c.getDescribe().getPicklistValues()) {
            if (genreEntry.isActive()) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + bookCount, 
                                                                 authors[Math.mod(bookCount++,10)].Id, 
                                                                 genreEntry.value, 
                                                                 176+bookCount, 
                                                                 publisher.Id, 
                                                                 System.today().addMonths(-5)));
            }
        } 

        while (bookCount<10) {
                books.add(FullBookStoreTestDataFactory.BuildBook('Test Title ' + bookCount, 
                                                                 authors[Math.mod(bookCount++,10)].Id, 
                                                                 'Fantasy',
                                                                 176+bookCount, 
                                                                 publisher.Id, 
                                                                 System.today().addMonths(-5)));
        }

        insert books;

        Test.startTest();
        Integer rating=pubSum.getPublisherRating();
        Test.stopTest();

        Assert.areEqual(100, rating,
                'Rating with 10 books and recently published (everything else maxed) should be 100');
    }              

    /*  Test Case 23 - Summary without any books published */
    @isTest
    static void TestGetSummaryNoBooksPublished() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Bob Buzzard & Co');

        Author__c author=FullBookStoreTestDataFactory.CreateAuthor('Han Solo', publisher.Id, '1');

        List<Book__c> books=new List<Book__c>();
        books.add(FullBookStoreTestDataFactory.BuildBook('My Life as a Freebooter', author.Id, 
                                                         'Biography', 176, publisher.Id, null));
        books.add(FullBookStoreTestDataFactory.BuildBook('Moving on from the Death Star', author.Id, 
                                                         'Biography', 75, publisher.Id, null));
        insert books;

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);
        pubSum.collectAuthorDetail();
        pubSum.collectBookDetail();

        Test.startTest();
        String summary=pubSum.getSummary();
        Test.stopTest();

        Assert.isTrue(summary.contains('0 published authors'),
                'Summary without any published books should give 0 publshed authors');

        Assert.isFalse(summary.contains('top rated authors'),
                'Summary without any published books should not include top rated authors');

        Assert.isTrue(summary.contains('0 books published'),
                'Summary without any published books should give 0 books publshed');

        Assert.isFalse(summary.contains('Genres'),
                'Summary without any published books should not include genres');
    }    

    /*  Test Case 24 - Summary without any authors associated with the publisher */
    @isTest
    static void TestGetSummaryNoAuthors() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Bob Buzzard & Co');
        Publisher__c publisherSummarised = FullBookStoreTestDataFactory.CreatePublisher('Leanpub');

        Author__c author=FullBookStoreTestDataFactory.CreateAuthor('Han Solo', publisher.Id, '1');

        List<Book__c> books=new List<Book__c>();
        books.add(FullBookStoreTestDataFactory.BuildBook('My Life as a Freebooter', author.Id, 
                                                         'Biography', 176, publisher.Id, System.today()));
        books.add(FullBookStoreTestDataFactory.BuildBook('Moving on from the Death Star', author.Id, 
                                                         'Biography', 75, publisher.Id, System.today()));
        insert books;

        PublisherSummary pubSum=new PublisherSummary(publisherSummarised.Id);
        pubSum.collectAuthorDetail();
        pubSum.collectBookDetail();

        Test.startTest();
        String summary=pubSum.getSummary();
        Test.stopTest();

        System.debug('Summary is ' + summary);

        Assert.isTrue(summary.contains('0 published authors'),
                'Summary without any authors 0 publshed authors');

        Assert.isFalse(summary.contains('top rated authors'),
                'Summary without any authors should not include top rated authors');

        Assert.isTrue(summary.contains('0 books published'),
                'Summary without any authors should give 0 books publshed');

        Assert.isFalse(summary.contains('Genres'),
                'Summary without any authors should not include genres');

    }    

    /*  Test Case 25 - Rate the publisher without any books published */
    @isTest
    static void TestRatePublisherNoBooksPublished() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Bob Buzzard & Co');

        Author__c author=FullBookStoreTestDataFactory.CreateAuthor('Han Solo', publisher.Id, '5');

        List<Book__c> books=new List<Book__c>();
        books.add(FullBookStoreTestDataFactory.BuildBook('My Life as a Freebooter', author.Id, 
                                                         'Biography', 176, publisher.Id, null));
        books.add(FullBookStoreTestDataFactory.BuildBook('Moving on from the Death Star', author.Id, 
                                                         'Biography', 75, publisher.Id, null));
        insert books;

        PublisherSummary pubSum=new PublisherSummary(publisher.Id);

        Test.startTest();
        Integer pubRating=pubSum.getPublisherRating();
        Test.stopTest();

        Integer deductionForGenres=0;
        for (Schema.PicklistEntry genreEntry : Book__c.Genre__c.getDescribe().getPicklistValues()) {
            if (genreEntry.isActive()) {
                deductionForGenres+=2;
            }
        } 

        Integer expectedRating=70-deductionForGenres;
        Assert.areEqual(expectedRating, pubRating,
                        'Published rating should deduct 10 for nothing published/no published authors' +
                        ' and 20 for low average author rating ' + 
                        ' and ' + deductionForGenres + ' for no book for any genre');
    }    

    /*  Test Case 26 - Rate the publisher without any authors associated with it */
    @isTest
    static void TestRatePublisherNoAuthors() {
        Publisher__c publisher = FullBookStoreTestDataFactory.CreatePublisher('Bob Buzzard & Co');
        Publisher__c publisherSummarised = FullBookStoreTestDataFactory.CreatePublisher('Leanpub');

        Author__c author=FullBookStoreTestDataFactory.CreateAuthor('Han Solo', publisher.Id, '1');

        List<Book__c> books=new List<Book__c>();
        books.add(FullBookStoreTestDataFactory.BuildBook('My Life as a Freebooter', author.Id, 
                                                         'Biography', 176, publisher.Id, System.today()));
        books.add(FullBookStoreTestDataFactory.BuildBook('Moving on from the Death Star', author.Id, 
                                                         'Biography', 75, publisher.Id, System.today()));
        insert books;

        PublisherSummary pubSum=new PublisherSummary(publisherSummarised.Id);

        Test.startTest();
        Integer pubRating=pubSum.getPublisherRating();
        Test.stopTest();

        Integer deductionForGenres=0;
        for (Schema.PicklistEntry genreEntry : Book__c.Genre__c.getDescribe().getPicklistValues()) {
            if (genreEntry.isActive()) {
                deductionForGenres+=2;
            }
        } 

        Integer expectedRating=70-deductionForGenres;
        Assert.areEqual(expectedRating, pubRating,
                        'Published rating should deduct 10 for no published authors/no books published' +
                        ' and 20 for low average author rating ' + 
                        ' and ' + deductionForGenres + ' for no book for any genre');
    }    

    /*  Test Case 27 - Construct the `PublisherSummary` class with a null `publisherId` parameter */
    @isTest
    static void TestNullPublisherId() {
        Test.startTest();
        try {
            PublisherSummary pubSum=new PublisherSummary(null);
            Assert.fail('Expected exception when null publisher supplied for summary');
        }
        catch (BookStoreException bse) {
            // expected
        }
        Test.stopTest();
    }    
}