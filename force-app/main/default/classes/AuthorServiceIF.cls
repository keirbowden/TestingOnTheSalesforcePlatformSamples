public interface AuthorServiceIF {
    void publishBooks(Author__c author, List<Book__c> books);
    void scheduleReading(Book__c book, DateTime starts, DateTime ends,
                         Boolean virtualReading);

}