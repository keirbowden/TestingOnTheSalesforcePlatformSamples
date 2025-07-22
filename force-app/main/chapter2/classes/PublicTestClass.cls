@isTest
public class PublicTestClass
{
    public static void Test() {
        Account acc=new Account(Name='Unit Test');
        insert acc;

        System.assertNotEquals(null, acc.Id);
    }
}