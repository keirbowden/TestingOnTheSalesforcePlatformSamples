public with sharing class ContactDAOStub implements ContactDAOIF{
    public ContactDAOStub() {
    }

    public Map<Id, Integer> openTaskCountForContacts;

    public Map<Id, Integer> getOpenTaskCountForContacts(Set<Id> contactIds) {
        return openTaskCountForContacts;
    }
}