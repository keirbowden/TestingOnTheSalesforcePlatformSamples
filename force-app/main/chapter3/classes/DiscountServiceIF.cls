public interface DiscountServiceIF {
    Integer calculateDiscount(Opportunity opp, 
                              List<OpportunityLineItem> olis);
}