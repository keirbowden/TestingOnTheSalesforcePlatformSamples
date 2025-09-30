@IsTest
public class BookStoreDAOUpdateBooksSpy implements BookStoreDAOIF {

    public List<UpdateBooksSpyRecord> updateBooksHistory=new List<UpdateBooksSpyRecord>();

    public class UpdateBooksSpyRecord {
        public List<Book__c> books;

        public UpdateBooksSpyRecord(List<Book__c> books) {
            this.books = books;
        }
    }

    public BookStoreDAOUpdateBooksSpy() {}

    public void createBooks(List<Book__c> books) {}

    public void updateBooks(List<Book__c> books) {
        updateBooksHistory.add(new UpdateBooksSpyRecord(books));
    }

    public void createAuthor(Author__c author) {}

    public void createAuthorReading(Author_Reading__c reading) {}

    public void createTask(Task task){}

    public void createEvent(Event event){}

    public Author__c getAuthor(Id authorId) {
        return null;
    }

    public List<Book__c> getBooksForAuthorName(String authorName) {
        return null;
    }
}
