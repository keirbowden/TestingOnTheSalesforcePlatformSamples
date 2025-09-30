@IsTest
private class user_biTest {
    @IsTest
    static void TestExperienceLevelSet() {
        Profile prof=[select id from Profile
                    where name='System Administrator'];

        User user = new User(Alias = 'unitTest',
                            Email='testuser@testorg.com',
                            EmailEncodingKey='UTF-8',
                            LastName='Testing',
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_GB',
                            ProfileId = prof.Id,
                            TimeZoneSidKey='Europe/London',
                            Username='unit.test@bobbuzz.' + System.now().getTime());

        insert user;

        User userFromDB=[select id, Experience_Level__c from User where id=:user.id];

        Assert.areEqual('Newbie', userFromDB.Experience_Level__c);
    }

    @IsTest
    static void TestExperienceLevelSetBulk() {
        Profile prof=[select id from Profile
                        where name='System Administrator'];

        List<User> users=new List<User>();
        for (Integer idx=0; idx<200; idx++) {
            users.add(new User(Alias = 'unitTest',
                                Email='testuser@testorg.com',
                                EmailEncodingKey='UTF-8',
                                LastName='Testing',
                                LanguageLocaleKey='en_US',
                                LocaleSidKey='en_GB',
                                ProfileId = prof.Id,
                                TimeZoneSidKey='Europe/London',
                                Username='unit.test@bobbuzz.' + idx + '.' + 
                                         System.now().getTime()));
        }
        insert users;

        List<User> usersFromDB=[select id, Experience_Level__c from User where id IN :users];

        Assert.areEqual(200, usersFromDB.size(),
                        'Should be 200 users inserted');

        for (Integer idx=0; idx<200; idx++){
            Assert.areEqual('Newbie', usersFromDB[idx].Experience_Level__c,
                            'Experience level should be set to \'Newbie\' at index ' + idx);
        }
    }
} 