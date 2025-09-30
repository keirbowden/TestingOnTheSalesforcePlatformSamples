@IsTest
private class ChatterGroupUtilsTest {

    static String TEST_GROUP_NAME='Test Future Group ' + Date.today();

    static CollaborationGroup CreateCollabGroup(){
        CollaborationGroup collabGroup=new CollaborationGroup(Name=TEST_GROUP_NAME,
					        						          CollaborationType='Public');

        insert collabGroup;

        return collabGroup;
    }

    @isTest
    static void TestOneWelcomePost() {
        CollaborationGroup collabGroup=CreateCollabGroup();
        ChatterGroupUtils.GROUP_NAME=TEST_GROUP_NAME;
            
        Test.startTest();   
        ChatterGroupUtils.PostWelcomeUsersToGroupFuture(new Set<Id>{UserInfo.getUserId()});
        Test.stopTest();

        List<FeedItem> feedItems=[select id, body 
                                    from FeedItem 
                                    where ParentId=:collabGroup.Id];

        Assert.areEqual(1, feedItems.size(),
                    'Inserting one user should generate one welcome post');
    }

    @isTest
    static void TestWelcomePostIsAsync() {
        CollaborationGroup collabGroup=CreateCollabGroup();
        ChatterGroupUtils.GROUP_NAME=TEST_GROUP_NAME;
            
        Test.startTest();   
        ChatterGroupUtils.PostWelcomeUsersToGroupFuture(new Set<Id>{UserInfo.getUserId()});
        List<FeedItem> feedItems=[select id, body 
                                    from FeedItem 
                                    where ParentId=:collabGroup.Id];
        System.assertEquals(0, feedItems.size(),
                            'Welcome post should not be generated until Test.stopTest() executes');
        Test.stopTest();

        feedItems=[select id, body 
                   from FeedItem 
                   where ParentId=:collabGroup.Id];

        Assert.areEqual(1, feedItems.size(),
                    'Inserting one user should generate one welcome post');
    }

    @isTest
    static void TestWelcomePostsEmptyUserCollection() {
        CollaborationGroup collabGroup=CreateCollabGroup();
        ChatterGroupUtils.GROUP_NAME=TEST_GROUP_NAME;

        Test.startTest();        
        ChatterGroupUtils.PostWelcomeUsersToGroupFuture(new Set<Id>());        
        Test.stopTest();

        List<FeedItem> feedItems=[select id 
        				      	 from FeedItem 
        					     where ParentId=:collabGroup.Id];

        Assert.areEqual(0, feedItems.size(),
                    'Empty set of user ids should not generate any welcome posts');
    }

    @isTest
    static void TestWelcomePostsNullUserCollection() {
        CollaborationGroup collabGroup=CreateCollabGroup();
        ChatterGroupUtils.GROUP_NAME=TEST_GROUP_NAME;

        Test.startTest();        
        ChatterGroupUtils.PostWelcomeUsersToGroupFuture(null);        
        Test.stopTest();

        List<FeedItem> feedItems=[select id 
        				      	 from FeedItem 
        					     where ParentId=:collabGroup.Id];

        Assert.areEqual(0, feedItems.size(),
                    'Null set of user ids should not generate any welcome posts');
    }

    @isTest
    static void TestZeroWelcomePosts() {
        CollaborationGroup collabGroup=CreateCollabGroup();
        ChatterGroupUtils.GROUP_NAME=TEST_GROUP_NAME;

        Test.startTest();        
        ChatterGroupUtils.PostWelcomeUsersToGroup(new List<User>());        
        Test.stopTest();

        List<FeedItem> feedItems=[select id 
        				      	 from FeedItem 
        					     where ParentId=:collabGroup.Id];

        Assert.areEqual(0, feedItems.size(),
                    'Empty list of user ids should not generate any welcome posts');
    }

    @isTest
    static void TestWelcomePostsMissingGroup() {
        ChatterGroupUtils.GROUP_NAME=TEST_GROUP_NAME;

        Test.startTest();        
        ChatterGroupUtils.PostWelcomeUsersToGroup(new List<User>{new User(Id=UserInfo.getUserId(),
                                                                          Username=UserInfo.getUserName())});
        Test.stopTest();

        List<FeedItem> feedItems=[select id 
        				      	 from FeedItem];

        Assert.areEqual(0, feedItems.size(),
                    'Missing chatter group should not generate any welcome posts');
   }
}