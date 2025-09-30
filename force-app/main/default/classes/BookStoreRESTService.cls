@RestResource(urlMapping='/bookstore/*')
global with sharing class BookStoreRESTService {
    @TestVisible
    static BookStoreDAOIF storeDAO=new BookStoreDAO();

    // Example: GET /services/apexrest/bookstore/booksByAuthor?authorName=Neil%20Gaiman
    @HttpGet
    global static List<BookDTO> getBooksByAuthor() {
        RestRequest req = RestContext.request;
        String authorName = req.params.get('authorName');
        if (String.isBlank(authorName)) {
            RestContext.response.statusCode = 400;
            return new List<BookDTO>();
        }

        List<Book__c> books = storeDAO.getBooksForAuthorName(authorName);

        return convertToBookDTOs(books);
    }

    // POST /services/apexrest/bookstore/authorWithBooks
    @HttpPost
    global static CreateAuthorAndBooksResponse createAuthorWithBooks() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            CreateAuthorAndBooksRequest requestData = 
                (CreateAuthorAndBooksRequest) JSON.deserialize(req.requestBody.toString(), CreateAuthorAndBooksRequest.class);

            System.debug('Request data = ' + requestData);
            if (requestData == null || String.isBlank(requestData.name) || requestData.books == null || requestData.books.isEmpty()) {
                res.statusCode = 400;
                return new CreateAuthorAndBooksResponse(false, null, new List<Id>(), 'Invalid request: author name and at least one book are required.');
            }

            Author__c author = new Author__c(
                Name = requestData.name,
                Email_Address__c = requestData.emailAddress
            );
            storeDAO.createAuthor(author);

            List<Book__c> books = new List<Book__c>();
            for (BookDTO b : requestData.books) {
                books.add(new Book__c(
                    Name = b.title,
                    Genre__c = b.genre,
                    Pages__c = b.pages,
                    Published_Date__c = b.publishedDate,
                    Author__c = author.Id
                ));
            }
            storeDAO.createBooks(books);

            res.statusCode = 201; 
            return new CreateAuthorAndBooksResponse(true, author.Id, 
                                            new List<Id>(new Map<Id,Book__c>(books).keySet()), 
                                            'Author and books created successfully.');

        } catch (Exception e) {
            res.statusCode = 500;
            return new CreateAuthorAndBooksResponse(false, null, new List<Id>(), 'Error: ' + e.getMessage());
        }
    }

    private static List<BookDTO> convertToBookDTOs(List<Book__c> books) {
        List<BookDTO> results = new List<BookDTO>();
        for (Book__c b : books) {
            results.add(new BookDTO(
                b.Id,
                b.Name,
                b.Genre__c,
                b.Published_Date__c,
                b.Pages__c,
                b.Author__r != null ? b.Author__r.Name : null,
                b.Publisher__r != null ? b.Publisher__r.Name : null
            ));
        }
        return results;
    }

    global class BookDTO {
        public Id id;
        public String title;
        public String genre;
        public Date publishedDate;
        public Integer pages;
        public String authorName;
        public String publisherName;

        public BookDTO(Id id, String title, String genre, Date publishedDate, Decimal pages, 
                        String authorName, String publisherName) {
            this.id = id;
            this.title = title;
            this.genre = genre;
            this.publishedDate = publishedDate;
            this.pages = Integer.valueOf(pages);
            this.authorName = authorName;
            this.publisherName = publisherName;
        }
    }

    global class CreateAuthorAndBooksRequest {
        public String name;
        public String emailAddress;
        public List<BookDTO> books;
    }

    global class CreateAuthorAndBooksResponse {
        public Boolean success;
        public Id authorId;
        public List<Id> bookIds;
        public String message;
        public CreateAuthorAndBooksResponse(Boolean success, Id authorId, List<Id> bookIds, String message) {
            this.success = success;
            this.authorId = authorId;
            this.bookIds = bookIds;
            this.message = message;
        }
    }
}