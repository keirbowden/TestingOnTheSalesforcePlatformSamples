@IsTest
public class BookStoreTestDataFactory {
    public static Author__c BuildAuthor(String name, Id publisherId) {
        Author__c author=new Author__c(Name=name,
                                       Publisher__c=publisherId);

        return author;
    }

    public static Author__c CreateAuthor(String name, Id publisherId) {
        Author__c author=BuildAuthor(name, publisherId);
        insert author;

        return author;
    }

    public static Publisher__c BuildPublisher(String name) {
        Publisher__c publisher=new Publisher__c(Name=name);

        return publisher;
    }

    public static Publisher__c CreatePublisher(String name) {
        Publisher__c publisher=BuildPublisher(name);
        insert publisher;

        return publisher;
    }

    public static Book__c BuildBook(String name, Id authorId,
                                    String genre, Integer pageCount) {
        Book__c book=new Book__c(Name=name,
                                 Author__c=authorId,
                                 Genre__c=genre,
                                 Pages__c=pageCount);

        return book;
    }

    public static Book__c CreateBook(String name, Id authorId,
                                     String genre, Integer pageCount) {
        Book__c book=BuildBook(name, authorId, genre, pageCount);
        insert book;

        return book;
    }
}