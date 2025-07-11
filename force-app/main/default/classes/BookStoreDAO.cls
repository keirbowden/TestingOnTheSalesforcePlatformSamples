public with sharing class BookStoreDAO implements BookStoreDAOIF {
    public BookStoreDAO() {

    }

    public void updateBooks(List<Book__c> books) {
        update books;
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
}
