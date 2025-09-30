public with sharing class BookStoreDAO implements BookStoreDAOIF {
    public BookStoreDAO() {

    }

    public void createBooks(List<Book__c> books) {
        insert books;
    }

    public void updateBooks(List<Book__c> books) {
        update books;
    }

    public void createAuthor(Author__c author) {
        insert author;
    }

    public void createAuthorReading(Author_Reading__c reading) {
        insert reading;
    }

    public void createTask(Task task){
        insert task;
    }

    public void createEvent(Event event){
        insert event;
    }

    public Author__c getAuthor(Id authorId) {
        Author__c author=[select id, Name, Publisher__c 
                          from Author__c
                          where id=:authorId];

        return author;
    }

    public List<Book__c> getBooksForAuthorName(String authorName) {
        List<Book__c> books = [
            select Id, Name, Genre__c, Published_Date__c, Pages__c,
                   Author__r.Name, Publisher__r.Name
            from Book__c
            where Author__r.Name = :authorName
            order by Name
        ];

        return books;
    }
}
