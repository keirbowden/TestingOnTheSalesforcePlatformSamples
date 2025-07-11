public class DiscountServiceDelegatingSpy implements DiscountServiceIF {

    public class CalculateDiscountSpyRecord {
        public Opportunity opp;
        public List<OpportunityLineItem> olis;

        public CalculateDiscountSpyRecord(Opportunity opp, List<OpportunityLineItem> olis) {
            this.opp = opp;
            this.olis = olis;
        }
    }

    public List<CalculateDiscountSpyRecord> calculateDiscountHistory = new List<CalculateDiscountSpyRecord>();

    private DiscountServiceIF realDiscountService;

    public DiscountServiceDelegatingSpy(DiscountServiceIF realDiscountService) {
        this.realDiscountService=realDiscountService;
    }

    public Integer calculateDiscount(Opportunity opp, List<OpportunityLineItem> olis) {
        calculateDiscountHistory.add(new CalculateDiscountSpyRecord(opp, olis));

        return realDiscountService.calculateDiscount(opp, olis);
    }
}