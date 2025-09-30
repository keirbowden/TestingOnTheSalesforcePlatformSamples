@isTest
public class DiscountServicePassiveSpy implements DiscountServiceIF {

    public class CalculateDiscountSpyRecord {
        public Opportunity opp;
        public List<OpportunityLineItem> olis;

        public CalculateDiscountSpyRecord(Opportunity opp, List<OpportunityLineItem> olis) {
            this.opp = opp;
            this.olis = olis;
        }
    }

    public List<CalculateDiscountSpyRecord> calculateDiscountHistory = new List<CalculateDiscountSpyRecord>();

    public Integer calculateDiscount(Opportunity opp, List<OpportunityLineItem> olis) {
        calculateDiscountHistory.add(new CalculateDiscountSpyRecord(opp, olis));

        return 0;
    }
}