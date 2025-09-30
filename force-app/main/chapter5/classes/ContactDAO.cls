public with sharing class ContactDAO implements ContactDAOIF{
    public ContactDAO() {
    }

    public Map<Id, Integer> getOpenTaskCountForContacts(Set<Id> contactIds) {
        Map<Id, Integer> openTaskCountByContactId=new Map<Id, Integer>();
        List<AggregateResult> aggResults=
                        [select count(id) num, WhoId ContId from Task
                        where WhoId in :contactIds
                          and IsClosed=false
                        group by WhoId];


        for (AggregateResult ar : aggResults) {
            Integer num=(Integer) ar.get('num');
            Id contactId=(Id) ar.get('ContId');
            openTaskCountByContactId.put(contactId, num);
        }

        return openTaskCountByContactId;
    }
}