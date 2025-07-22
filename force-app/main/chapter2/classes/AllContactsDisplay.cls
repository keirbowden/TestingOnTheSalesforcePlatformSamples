   public with sharing class AllContactsDisplay {
    public List<Contact> contacts {get; set;}

    @TestVisible private static Integer PAGE_SIZE=50;

    public AllContactsDisplay() { 
        contacts=[select id, Name from Contact];
    }

    public Boolean showNext() {
        return contacts.size()>PAGE_SIZE;
    }
}	