@IsTest
private class RunAsUserTest {
    @IsTest
    static void testRunAs() {
        Profile prof=[select id from Profile 
                      where name='Minimum Access - Salesforce'];

        User user = new User(Alias = 'unitTest', 
                            Email='testuser@testorg.com', 
                            EmailEncodingKey='UTF-8', 
                            LastName='Testing', 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_GB', 
                            ProfileId = prof.Id, 
                            TimeZoneSidKey='Europe/London', 
                            Username='unit.test@bobbuzz.' + System.now().getTime());

        System.debug('DML statements = ' + Limits.getDMLStatements());
        System.debug('DML statements = ' + Limits.getDMLStatements());
        System.runAs(user) {

        }
        System.debug('DML statements = ' + Limits.getDMLStatements());
    }
}