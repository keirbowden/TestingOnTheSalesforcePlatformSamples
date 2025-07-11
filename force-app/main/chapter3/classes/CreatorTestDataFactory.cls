@IsTest
public class CreatorTestDataFactory {
    public static Opportunity CreateOpportunity() {
        return CreateOpportunity('Test Opp', 
                                 30000, 
                                 System.today().addDays(90),
                                 'Prospecting');
    }

    public static Opportunity CreateOpportunity(String name, Double amount,
                                                Date closeDate, String stageName) {
        Opportunity opp=new Opportunity(Name=name,
                                        Amount=amount,
                                        CloseDate=closeDate,
                                        StageName=stageName);
                   
        insert opp;
        return opp;
    }
}