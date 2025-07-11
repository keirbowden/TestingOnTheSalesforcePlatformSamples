public with sharing class DiscountServiceMock {
    public Integer expectedCalculateDiscountCallCount=1;
    public Double expectedCalculateDiscountOppAmount=250000;

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

    public List<String>  verify() {
        List<String> errors=new List<String>();
        if (expectedCalculateDiscountCallCount!=calculateDiscountHistory.size()) {
            errors.add('calculateDiscount should be called ' + 
                       expectedCalculateDiscountCallCount + 
                       ' times, but was actually called ' + 
                       calculateDiscountHistory.size() + ' times.');
        }

        if (expectedCalculateDiscountOppAmount!=calculateDiscountHistory[0].opp.Amount) {
            errors.add('calculateDiscount should be called with an opportunity amount of' + 
                        expectedCalculateDiscountOppAmount + 
                        ', but was actually called with an opportunity amount of ' + 
                        calculateDiscountHistory[0].opp.Amount);
        }

        return errors;
    }
}