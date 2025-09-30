@isTest
public with sharing class DiscountServiceStub implements DiscountServiceIF {

    private Integer discount;

    public DiscountServiceStub(Integer discount) {
        this.discount=discount;
    }

    public Integer calculateDiscount(Opportunity opp, 
                                    List<OpportunityLineItem> olis) {
        return discount;
    }
}