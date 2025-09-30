trigger contact_bd on Contact (before delete) {
    ContactUtils contactUtils=new ContactUtils();
    
    List<Id> errorIds=contactUtils.validateDelete(Trigger.oldMap);
    contactUtils.addDeleteTaskViolationsToRecords(errorIds, Trigger.oldMap);
}