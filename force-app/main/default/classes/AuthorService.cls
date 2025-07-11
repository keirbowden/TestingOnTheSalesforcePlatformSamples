public with sharing class AuthorService implements AuthorServiceIF {
    @TestVisible
    private BookStoreDAOIF storeDAO;

    public AuthorService() {
        storeDAO=new BookStoreDAO();    
    }

    public void publishBooks(Author__c author, List<Book__c> books) {
        if (null==author)
        {
            throw new BookStoreException('Cannot publish books without specifying author');
        }

        if (null==books)
        {
            throw new BookStoreException('Cannot publish null collection of books');
        }

        List<Book__c> booksToUpdate=new List<Book__c>();

        for (Book__c book : books)
        {
            if (null!=book) {
                book.Published_Date__c=System.today();
                book.Publisher__c=author.Publisher__c;
                booksToUpdate.add(book);
            }
        }

        storeDAO.updateBooks(booksToUpdate);
    }

    public void scheduleReading(Book__c book, DateTime starts, DateTime ends,
                                Boolean virtualReading) {
        if (null==book)
        {
            throw new BookStoreException('A reading must specify a book');
        }

        if (null==starts)
        {
            throw new BookStoreException('Must specify reading start date and time');
        }

        if (null==ends)
        {
            throw new BookStoreException('Must specify reading end date and time');
        }

        if (null==virtualReading)
        {
            virtualReading=false;
        }

        Author__c author=storeDAO.getAuthor(book.Author__c);

        Author_Reading__c reading=new Author_Reading__c(Book__c=book.Id,
                                                        Starts__c=starts,
                                                        Ends__c=ends,
                                                        Virtual__c=virtualReading);
        storeDAO.createAuthorReading(reading);

        createSendInvitesTask('Reading', ends.date().addDays(-1), reading.Id);

        if (virtualReading) {
            createVideoConference(reading, author, book, starts, ends);
        }
    }

    private Task createSendInvitesTask(String eventType, Date dueDate, Id whatId) {
        Task sendInvites = new Task();
        sendInvites.Subject = 'Send Invitations to ' + eventType;
        sendInvites.Status = 'Not Started';
        sendInvites.Priority = 'Normal';
        sendInvites.ActivityDate = dueDate;
        sendInvites.WhatId = whatId;
        sendInvites.OwnerId = UserInfo.getUserId();

        storeDAO.createTask(sendInvites);

        return sendInvites;
    }

    private Event createVideoConference(Author_Reading__c reading, Author__c author, Book__c book,
                                       DateTime starts, DateTime ends) {
        Event videoConference = new Event();
        videoConference.Subject = 'Reading of ' + book.Name + ' by ' + author.Name;
        videoConference.StartDateTime = starts;
        videoConference.EndDateTime = ends;
        videoConference.Location = 'Online';
        videoConference.WhatId = reading.Id;
        videoConference.OwnerId = UserInfo.getUserId();

        storeDAO.createEvent(videoConference);

        return videoConference;
    }
}