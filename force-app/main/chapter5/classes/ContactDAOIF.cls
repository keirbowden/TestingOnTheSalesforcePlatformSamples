public interface ContactDAOIF {
    Map<Id, Integer> getOpenTaskCountForContacts(Set<Id> contactIds);
}