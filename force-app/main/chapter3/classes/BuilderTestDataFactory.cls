@IsTest
public class BuilderTestDataFactory {
    public static Opportunity CreateOpportunity() {
        return CreateOpportunity('Test Opp');
    }

    public static Opportunity CreateOpportunity(String name) {
        return CreateOpportunity(name, 30000);
    }

    public static Opportunity CreateOpportunity(String name, Double amount) {
        return CreateOpportunity(name, 
                                 amount, 
                                 System.today().addDays(90),
                                 'Prospecting');
    }

    public static Opportunity CreateOpportunity(String name, Double amount,
                                                Date closeDate, String stageName) {
        Opportunity opp=new Opportunity(Name=name,
                                        Amount=amount,
                                        CloseDate=closeDate,
                                        StageName=stageName);
                   
        return opp;
    }
}