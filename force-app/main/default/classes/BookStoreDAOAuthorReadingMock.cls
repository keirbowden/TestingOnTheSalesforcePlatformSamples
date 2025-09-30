@IsTest
public with sharing class BookStoreDAOAuthorReadingMock implements BookStoreDAOIF {
    
    public List<CreateAuthorReadingRecord> createAuthorReadingHistory=new List<CreateAuthorReadingRecord>();

    public class CreateAuthorReadingRecord {
        public Author_Reading__c reading;

        public CreateAuthorReadingRecord(Author_Reading__c reading) {
            this.reading = reading;
        }
    }

    public Integer expectedAuthorReadingCount;
    public List<Author_Reading__c> expectedReadings=new list<Author_Reading__c>();

    public List<CreateTaskRecord> createTaskHistory=new List<CreateTaskRecord>();

    public class CreateTaskRecord {
        public Task task;

        public CreateTaskRecord(Task task) {
            this.task = task;
        }
    }

    public Integer expectedTaskCount;
    public List<Task> expectedTasks=new list<Task>();

    public List<CreateEventRecord> createEventHistory=new List<CreateEventRecord>();

    public class CreateEventRecord {
        public Event event;

        public CreateEventRecord(Event event) {
            this.event = event;
        }
    }

    public Integer expectedEventCount;
    public List<Event> expectedEvents=new list<Event>();


    public BookStoreDAOAuthorReadingMock() {}

    public void createBooks(List<Book__c> books) {}

    public void updateBooks(List<Book__c> books) {}

    public void createAuthor(Author__c author) {}

    public void createAuthorReading(Author_Reading__c reading) {
        createAuthorReadingHistory.add(new CreateAuthorReadingRecord(reading));
    }

    public void createTask(Task task){
        createTaskHistory.add(new CreateTaskRecord(task));
    }

    public void createEvent(Event event){
        createEventHistory.add(new CreateEventRecord(event));
    }

    public Author__c getAuthor(Id authorId) {
        return new Author__c(Name='Keir Bowden');
    }

    public List<Book__c> getBooksForAuthorName(String authorName) {
        return null;
    }

    public List<String> verify() {
        List<String> errors=new List<String>();

        if (null!=expectedAuthorReadingCount){
            if (expectedAuthorReadingCount!=createAuthorReadingHistory.size()) {
                errors.add('Expected ' + expectedAuthorReadingCount + 
                            ' author readings, but was ' + 
                            createAuthorReadingHistory.size());
            }
            else {
                for (Integer idx=0; idx<expectedAuthorReadingCount; idx++) {
                    if (expectedReadings[idx].Book__c!=createAuthorReadingHistory[idx].reading.Book__c) {
                        errors.add('Expected book on reading of ' + expectedReadings[idx].Book__c + 
                                ' at position ' + idx + ' but was ' + 
                                createAuthorReadingHistory[0].reading.Book__c);
                    }
                    if (expectedReadings[idx].Starts__c!=createAuthorReadingHistory[idx].reading.Starts__c) {
                        errors.add('Expected start date/time on reading of ' + expectedReadings[idx].Starts__c + 
                                ' at position ' + idx + ' but was ' + 
                                createAuthorReadingHistory[0].reading.Starts__c);
                    }
                    if (expectedReadings[idx].Ends__c!=createAuthorReadingHistory[idx].reading.Ends__c) {
                        errors.add('Expected end date/time on reading of ' + expectedReadings[idx].Ends__c + 
                                ' at position ' + idx + ' but was ' + 
                                createAuthorReadingHistory[0].reading.Ends__c);
                    }
                    if (expectedReadings[idx].Virtual__c!=createAuthorReadingHistory[idx].reading.Virtual__c) {
                        errors.add('Expected virtual reading value of ' + expectedReadings[idx].Virtual__c + 
                                ' at position ' + idx + ' but was ' + 
                                createAuthorReadingHistory[0].reading.Virtual__c);
                    }
                }
            }
        }

        if (null!=expectedTaskCount) {
            if (expectedTaskCount!=createTaskHistory.size()) {
                errors.add('Expected ' + expectedTaskCount + 
                        ' tasks, but was ' + 
                        createTaskHistory.size());
            }
            else {
                for (Integer idx=0; idx<expectedTaskCount; idx++) {
                    if (expectedTasks[idx].ActivityDate!=createTaskHistory[idx].task.ActivityDate) {
                        errors.add('Expected due date on task of ' + 
                                    expectedTasks[idx].ActivityDate + 
                                ' at position ' + idx + ' but was ' + 
                                createTaskHistory[0].task.ActivityDate);
                    }
                }
            }
        }

        if (null!=expectedEventCount) {
            if (expectedEventCount!=createEventHistory.size()) {
                errors.add('Expected ' + expectedEventCount + 
                        ' events, but was ' + 
                        createEventHistory.size());
            }
            else {
                for (Integer idx=0; idx<expectedEventCount; idx++) {
                    if (expectedEvents[idx].StartDateTime!=createEventHistory[idx].event.StartDateTime) {
                        errors.add('Expected start date/time for event of ' + expectedEvents[idx].StartDateTime + 
                                ' at position ' + idx + ' but was ' + 
                                createEventHistory[0].event.StartDateTime);
                    }

                    if (expectedEvents[idx].EndDateTime!=createEventHistory[idx].event.EndDateTime) {
                        errors.add('Expected end date/time for event of ' + expectedEvents[idx].EndDateTime + 
                                ' at position ' + idx + ' but was ' + 
                                createEventHistory[0].event.EndDateTime);
                    }

                    if (expectedEvents[idx].Location!=createEventHistory[idx].event.Location) {
                        errors.add('Expected location for event of ' + expectedEvents[idx].Location + 
                                ' at position ' + idx + ' but was ' + 
                                createEventHistory[0].event.Location);
                    }
                }
            }
        }

        return errors;
    }
}