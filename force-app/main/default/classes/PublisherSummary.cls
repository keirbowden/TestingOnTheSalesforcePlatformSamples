public with sharing class PublisherSummary {
    private Id publisherId;
    private Publisher__c publisher;
    private Integer authorCount=-1;
    private Integer averageAuthorRating=0;
    private Integer topRatedAuthorCount=0;
    private Integer bookCount=-1;
    private Map<String, Integer> bookCountByGenre=new Map<String, Integer>();
    private Date lastPublishedDate;

    public PublisherSummary(Id publisherId) {
        if (null==publisherId) {
            throw new BookStoreException('Invalid publisher id : null');
        }
        this.publisherId=publisherId;
    }

    public void collectAuthorDetail() {
        List<AggregateResult> ratingGroups=[select count(Id) authorCount, Rating__c
                                          from Author__c
                                          where Publisher__c=:this.publisherId
                                          and   Number_Books_Published__c>0
                                          group by Rating__c];

        Integer totalAuthors=0;
        Integer totalRating=0;

        for (AggregateResult ratingGroup : ratingGroups) {
            Integer authorCount=(Integer) ratingGroup.get('authorCount');
            Integer rating=Integer.valueOf(ratingGroup.get('Rating__c'));
            if (5==rating) {
                this.topRatedAuthorCount=authorCount;
            }
            totalAuthors+=authorCount;
            totalRating+=(authorCount*rating);
        }

        this.authorCount=totalAuthors;
        if (totalAuthors>0) {
            this.averageAuthorRating=totalRating/totalAuthors;
        }
    }

    public void collectBookDetail() {
        List<Book__c> books=[select Id, Genre__c, Published_Date__c
                             from Book__c
                             where Published_Date__c!=null
                             and   Publisher__c=:this.publisherId];

        this.bookCount=books.size();
        for (Book__c book : books) {
            Integer genreCount=bookCountByGenre.get(book.Genre__c);
            if (null==genreCount) {
                genreCount=1;
            }
            else {
                genreCount++;
            }

            bookCountByGenre.put(book.Genre__c, genreCount);

            if ( (null==this.lastPublishedDate) || 
                 (this.lastPublishedDate>book.Published_Date__c) ) {
                this.lastPublishedDate=book.Published_Date__c;
            }
        }
    }

    public Integer getAuthorCount() {
        return this.authorCount;
    }

    public Integer getAverageAuthorRating() {
        return this.averageAuthorRating;
    }   

    public Integer getTopRatedAuthorCount() {
        return this.topRatedAuthorCount;
    }

    public Integer getBookCount() {
        return this.bookCount;
    }

    public Date getLastPublishedDate() {
        return this.lastPublishedDate;
    }

    public Publisher__c getPublisher() {
        if (null==this.publisher) {
            this.publisher=[select id, Name from Publisher__c where Id=:this.publisherId];
        }
        
        return this.publisher;
    }
    
    public String getSummary() {

        String summary=this.getPublisher().Name + ' Summary\n';
        if (-1!=authorCount) {
            summary+=this.authorCount + ' published authors\n';
            if (0!=authorCount) {
                summary+=this.averageAuthorRating + ' average author rating\n';
                summary+=this.topRatedAuthorCount + ' top rated authors\n';
            }
        }

        if (-1!=bookCount) {
            summary+=this.bookCount + ' books published\n';
            if (0!=this.bookCount) {
                summary+='Genres:\n';
                for (String genre : this.bookCountByGenre.keySet()) {
                    summary+=genre + ' - ' + this.bookCountByGenre.get(genre) + ' books\n';
                }
                if (null!=this.lastPublishedDate) {
                    summary+='Last published on: ' + this.lastPublishedDate.format();
                }
            }
        }

        return summary;
    }

    public Integer getPublisherRating() {
        if (-1==this.authorCount) {
            this.collectAuthorDetail();
        }

        if (-1==this.bookCount) {
            this.collectBookDetail();
        }

        Integer rating=100;

        for (Schema.PicklistEntry genreEntry : Book__c.Genre__c.getDescribe().getPicklistValues()) {
            if (genreEntry.isActive()) {
                Integer bookCountForGenre=this.bookCountByGenre.get(genreEntry.getValue());
                if (null==bookCountForGenre) {
                    System.debug('No books for genre ' + genreEntry.getValue());
                    rating-=2;
                }
            }
        } 

        if ( (authorCount<10 ) && (lastPublishedDate<System.today().addMonths(-3)) ||
             (bookCount<20 ) && (lastPublishedDate<System.today().addMonths(-6))) {
                System.debug('Deducting 10 at step 2');
            rating-=10;
        }

        if (averageAuthorRating<2) {
                System.debug('Deducting 20 at step 3');
            rating-=20;
        }

        if (0>=topRatedAuthorCount) {
                System.debug('Deducting 10 at step 4');
            rating-=10;
        }

        return rating;
    }
}