@IsTest
private class ExperienceUtilsTest {
    static final String LEVEL='Newbie';

    @IsTest
    static void TestSetExperienceLevelOne() {
        List<User> users=new List<User>();
        User u = new User();
        users.add(u);

        Test.startTest();
        ExperienceUtils.SetExperienceLevel(users, LEVEL);
        Test.stopTest();

        Assert.areEqual(level, u.Experience_Level__c,
                        'Experience level should be set to \'Newbie\'');
    }

    @IsTest
    static void TestSetExperienceLevelMany() {
        List<User> users=new List<User>();
        for (Integer idx=0; idx<200; idx++) {
            users.add(new User());
        }

        Test.startTest();
        ExperienceUtils.SetExperienceLevel(users, LEVEL);
        Test.stopTest();

        for (Integer idx=0; idx<200; idx++) {
            Assert.areEqual(level, users[idx].Experience_Level__c,
                            'Experience level should be set to \'Newbie\' at index ' + idx);
        }
    }

    @IsTest
    static void TestSetExperienceLevelZero() {
        List<User> users=new List<User>();

        Test.startTest();
        ExperienceUtils.SetExperienceLevel(users, LEVEL);
        Test.stopTest();

        Assert.areEqual(0, users.size(),
                        'User list should remain empty');
    }

    @IsTest
    static void TestSetExperienceLevelNullList() {
        List<User> users=null;

        Test.startTest();
        ExperienceUtils.SetExperienceLevel(users, LEVEL);
        Test.stopTest();

        Assert.areEqual(null, users,
                        'User list should remain null');
    }

    @IsTest
    static void TestSetExperienceLevelNullElement() {
        List<User> users=new List<User>();
        users.add(new User());
        users.add(null);
        users.add(new User());

        Test.startTest();
        ExperienceUtils.SetExperienceLevel(users, LEVEL);
        Test.stopTest();

        Assert.areEqual(LEVEL, users[0].Experience_Level__c,
                        'Experience level should be set to \'Newbie\' at index 0');
        Assert.areEqual(null, users[1],
                        'Element at index 1 should remain null');
        Assert.areEqual(LEVEL, users[2].Experience_Level__c,
                                'Experience level should be set to \'Newbie\' at index 2');
    }

    @IsTest
    static void TestSetExperienceLevelNullLevel() {
        List<User> users=new List<User>();
        User u = new User();
        users.add(u);

        Test.startTest();
        ExperienceUtils.SetExperienceLevel(users, null);
        Test.stopTest();

        Assert.areEqual(null, u.Experience_Level__c,
                        'Experience level should be left as null with null level');
    }


    @IsTest
    static void TestSetExperienceLevelNullListAndLevel() {
        List<User> users=null;

        Test.startTest();
        ExperienceUtils.SetExperienceLevel(users, null);
        Test.stopTest();

        Assert.areEqual(null, users,
                        'User list should remain null combined with null level');
    }
}
