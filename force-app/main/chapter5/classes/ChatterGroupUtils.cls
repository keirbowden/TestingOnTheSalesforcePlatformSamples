public with sharing class ChatterGroupUtils {
	@TestVisible
	private static String GROUP_NAME='All Employees';

	@future
	static public void PostWelcomeUsersToGroupFuture(Set<Id> userIds) {
        if (null!=userIds) {
		    List<User> users=[select id, FirstName, LastName, Username 
                              from User 
                              where id in :userIds];
   		
            PostWelcomeUsersToGroup(users);
        }
    }

	static public void PostWelcomeUsersToGroup(List<User> users) {
		List<CollaborationGroup> chatterGroups=
                                [select id, Name 
                                 from CollaborationGroup 
                                 where name=:GROUP_NAME];
    	
		if (1==chatterGroups.size()) {
            List<FeedItem> feedItems=new List<FeedItem>();
            if (users.size()>0) {
                for (User us : users) {
                    FeedItem feedItem = new FeedItem();
                    feedItem.ParentId = chatterGroups[0].id;
                    feedItem.Body = '\nPlease welcome ' + us.FirstName + ' ' + us.LastName + 
                                    ' (' + us.Username + ') to Salesforce';
                    feedItems.add(feedItem);
                }
            
                insert feedItems;
            }
        }
	}
}