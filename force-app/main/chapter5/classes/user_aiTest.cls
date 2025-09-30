@isTest
private class user_aiTest {
    static String TEST_GROUP_NAME='Test Future Group ' + Date.today();

    @TestSetup
    static void createCollabGroup(){
        CollaborationGroup collabGroup=new CollaborationGroup(Name=TEST_GROUP_NAME,
					        						          CollaborationType='Public');

        insert collabGroup;
    }

    static List<User> GetUsers(Integer numberOfUsers) {
        Profile prof=[select id 
                      from Profile
                      where name='System Administrator'];

        UserRole role=new UserRole(Name='Unit Test');
        insert role;        

        List<User> users=new List<User>();
        for (Integer idx=0; idx<numberOfUsers; idx++) {
            users.add(new User(Alias = 'unitTest',
                                Email='testuser@testorg.com',
                                EmailEncodingKey='UTF-8',
                                FirstName='Unit',
                                LastName='Testing' + idx,
                                LanguageLocaleKey='en_US',
                                LocaleSidKey='en_GB',
                                ProfileId = prof.Id,
                                UserRoleId=role.id,
                                TimeZoneSidKey='Europe/London',
                                Username='unit.test@bobbuzz.' + idx + System.now().getTime()));
        }

        return users;
    }

    @isTest
    static void TestOneWelcomePost() {
        ChatterGroupUtils.GROUP_NAME=TEST_GROUP_NAME;

        System.runAs(new User(Id=UserInfo.getUserId())) {
            List<User> users=GetUsers(1);

            Test.startTest();   
            insert users;        
            Test.stopTest();

            CollaborationGroup collabGroup=[select Id 
                                            from CollaborationGroup 
                                            where name=:TEST_GROUP_NAME];

            List<FeedItem> feedItems=[select id, body 
        	    			      	 from FeedItem 
        		    			     where ParentId=:collabGroup.Id];

            Assert.areEqual(1, feedItems.size(),
                        'Inserting one user should generate one welcome post');
        }
    }

    @isTest
    static void TestBulkWelcomePosts() {
        ChatterGroupUtils.GROUP_NAME=TEST_GROUP_NAME;

        System.runAs(new User(Id=UserInfo.getUserId())) {
            List<User> users=GetUsers(200);

            Test.startTest();        
            insert users;        
            Test.stopTest();

            CollaborationGroup collabGroup=[select Id 
                                            from CollaborationGroup 
                                            where name=:TEST_GROUP_NAME];

            List<FeedItem> feedItems=[select id 
        	    			      	 from FeedItem 
        		    			     where ParentId=:collabGroup.Id];

            Assert.areEqual(200, feedItems.size(),
                        'Inserting 200 users should generate 200 welcome posts');
        }
    }
}