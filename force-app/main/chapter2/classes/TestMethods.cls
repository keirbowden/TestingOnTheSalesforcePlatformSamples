@isTest
private class TestMethods {

    static testMethod void myTestMethodUnitTest() {
        Contact cont=new Contact(FirstName='Unit',
                                 Lastname='Test');
        insert cont;

        Assert.areEqual(null, cont.AccountId,
                        'Private contact must have a null ID');
    }    

    @isTest
    static void myIsTestUnitTest() {
        Contact cont=new Contact(FirstName='Unit',
                                 Lastname='Test');
        insert cont;

        Assert.areEqual(null, cont.AccountId,
                        'Private contact must have a null ID');
    }    

    //@isTest
    static void myNonRunningUnitTest() {
        Contact cont=new Contact(FirstName='Unit',
                                 Lastname='Test');
        insert cont;

        Assert.areEqual(null, cont.AccountId,
                        'Private contact must have a null ID');
    }    
}