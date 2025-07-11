public interface BookStoreDAOIF {
    void updateBooks(List<Book__c> books);
    void createAuthorReading(Author_Reading__c reading);
    void createTask(Task task);
    void createEvent(Event event);
    Author__c getAuthor(Id authorId);
}