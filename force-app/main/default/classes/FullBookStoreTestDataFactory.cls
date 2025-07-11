@IsTest
public class FullBookStoreTestDataFactory {
    public static Author__c BuildAuthor(String name, Id publisherId) {
        return BuildAuthor(name, publisherId, '3');
    }

    public static Author__c BuildAuthor(String name, Id publisherId, String rating ) {
        Author__c author=new Author__c(Name=name,
                                       Publisher__c=publisherId,
                                       Rating__c=rating);

        return author;
    }

    public static Author__c CreateAuthor(String name, Id publisherId) {
        return CreateAuthor(name, publisherId, '3');
    }

    public static Author__c CreateAuthor(String name, Id publisherId, String rating) {
        Author__c author=BuildAuthor(name, publisherId, rating);
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

        return BuildBook(name, authorId, genre, pageCount, null);
    }

    public static Book__c BuildBook(String name, Id authorId,
                                    String genre, Integer pageCount,
                                    Id publisherId) {
        return BuildBook(name, authorId, genre, pageCount, publisherId, null);
    }

    public static Book__c BuildBook(String name, Id authorId,
                                    String genre, Integer pageCount,
                                    Id publisherId, Date publishedDate) {
        Book__c book=new Book__c(Name=name,
                                 Author__c=authorId,
                                 Genre__c=genre,
                                 Pages__c=pageCount,
                                 Published_Date__c=publishedDate,
                                 Publisher__c=publisherId);

        return book;
    }

    public static Book__c CreateBook(String name, Id authorId,
                                     String genre, Integer pageCount) {
        return CreateBook(name, authorId, genre, pageCount, null);
    }

    public static Book__c CreateBook(String name, Id authorId,
                                    String genre, Integer pageCount,
                                    Id publisherId) {
        return CreateBook(name, authorId, genre, pageCount, publisherId, null);
    }

    public static Book__c CreateBook(String name, Id authorId,
                                    String genre, Integer pageCount,
                                    Id publisherId, Date publishedDate) {
        Book__c book=BuildBook(name, authorId, genre, pageCount, publisherId, publishedDate);
        insert book;                                        

        return book;
    }
}