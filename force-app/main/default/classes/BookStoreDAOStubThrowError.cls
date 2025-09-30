@isTest
public class BookStoreDAOStubThrowError implements BookStoreDAOIF {
    public void createBooks(List<Book__c> books) {
        throw new BookStoreException('Exception from stubbed createBooks');
    }

    public void updateBooks(List<Book__c> books){
        throw new BookStoreException('Exception from stubbed updateBooks');
    }

    public void createAuthor(Author__c author){
        throw new BookStoreException('Exception from stubbed createAuthor');
    }

    public void createAuthorReading(Author_Reading__c reading) {
        throw new BookStoreException('Exception from stubbed createAuthorReading'); 
    }

    public void createTask(Task task) {
        throw new BookStoreException('Exception from stubbed createTask');
    }

    public void createEvent(Event event) {
        throw new BookStoreException('Exception from stubbed createEvent');
    }

    public Author__c getAuthor(Id authorId) {
        throw new BookStoreException('Exception from stubbed getAuthor');
    }

    public List<Book__c> getBooksForAuthorName(String authorName) {
        throw new BookStoreException('Exception from stubbed getBooksForAuthorName');
    }
}