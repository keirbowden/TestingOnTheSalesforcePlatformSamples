public interface BookStoreDAOIF {
    void createBooks(List<Book__c> books);
    void updateBooks(List<Book__c> books);
    void createAuthor(Author__c author);
    void createAuthorReading(Author_Reading__c reading);
    void createTask(Task task);
    void createEvent(Event event);
    Author__c getAuthor(Id authorId);
    List<Book__c> getBooksForAuthorName(String authorName);
}