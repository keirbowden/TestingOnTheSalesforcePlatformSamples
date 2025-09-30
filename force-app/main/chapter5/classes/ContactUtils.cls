public with sharing class ContactUtils {
    @TestVisible
    private ContactDAOIF contactDAO;

    public ContactUtils() {
        contactDAO = new ContactDAO();  
    }
    
    public List<Id> validateDelete(Map<Id, Contact> contactsById) {
        Map<Id, Integer> openTaskCountByContact=
                this.contactDAO.getOpenTaskCountForContacts(contactsById.keySet());

        List<Id> errorIds=new List<Id>();

        for (Id contactId : openTaskCountByContact.keySet()) {
            if (openTaskCountByContact.get(contactId)>0) {
                errorIds.add(contactId);
            }
        }

        return errorIds;
    }

    public void addDeleteTaskViolationsToRecords(List<Id> errorIds, Map<Id, Contact> contactsById) {
        if (errorIds.size()>0) {
            // we're in trigger context - add errors to records
            for (Id errorId : errorIds) {
                contactsById.get(errorId).addError('Cannot delete contact with open Task');
            }
        }
    }

    public void raiseDeleteTaskViolations(List<Id> errorIds) {
        if (errorIds.size()>0) {
            // we're in non-trigger context - throw an exception identifying the ids
            String errorStr='Cannot delete contact(s) with open Task, Ids : ';
            for (Id errorId : errorIds) {
                errorStr+=errorId + ', ';
            }

            throw new ContactException(errorStr.substring(errorStr.length()-2));
        }
    }

    public void validateDeleteSniffTrigger(Map<Id, Contact> contactsById) {
        Map<Id, Integer> openTaskCountByContact=
                this.contactDAO.getOpenTaskCountForContacts(contactsById.keySet());

        List<Id> errorIds=new List<Id>();

        for (Id contactId : openTaskCountByContact.keySet()) {
            if (openTaskCountByContact.get(contactId)>0) {
                errorIds.add(contactId);
            }
        }

        if (errorIds.size()>0) {
            if (Trigger.isExecuting) {
                // we're in trigger context, so decorate the sobject with the error
                for (Id errorId : errorIds) {
                    contactsById.get(errorId).addError('Cannot delete contact with open Task');
                }
            }
            else {
                // we're in non-trigger context - throw an exception identifying the ids
                String errorStr='Cannot delete contact(s) with open Task, Ids : ';
                for (Id errorId : errorIds) {
                    errorStr+=errorId + ', ';
                }

                throw new ContactException(errorStr.substring(errorStr.length()-2));
            }
        }
    }
}