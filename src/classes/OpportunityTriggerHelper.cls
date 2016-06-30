/**
 * Helper for OpportunityTrigger
 * @author Digamber Prasad
 * */
public with sharing class OpportunityTriggerHelper {
    
    /**
    * Method which creates Quote, QuoteLineItem, Order and Order and OrderItem for given list of Opportunities
    * @param List<Opportunity>
    * @return void
    * */
    public static void createQuoteAndOrder(List<Opportunity> lstOpportunity){

        List<Quote> lstQuote = new List<Quote>();
        List<Order> lstOrder = new List<Order>();
        List<QuoteLineItem> lstQLI = new List<QuoteLineItem>();
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        Set<Id> setOpportunityId = new Set<Id>();
        Map<Id, List<OpportunityLineItem>> mapOLI = new Map<Id, List<OpportunityLineItem>>();

        for(Opportunity oppty : lstOpportunity){
            setOpportunityId.add(oppty.Id);
            /*
            lstQuote.add(new Quote(Name=oppty.Name, OpportunityId=oppty.Id, Pricebook2Id=oppty.Pricebook2Id, Purchasing_Member__c=oppty.Purchasing_Member__c
                ));
            */
            lstOrder.add(new Order(AccountId=oppty.AccountId, OpportunityId=oppty.Id, Pricebook2Id=oppty.Pricebook2Id, Status='Draft', 
                            EffectiveDate=System.today(), Purchasing_Member__c=oppty.Purchasing_Member__c
                            )
                        );
        }

        System.debug('setOpportunityId:-->' + setOpportunityId);

        for(OpportunityLineItem oli : [SELECT Id, ListPrice, OpportunityId, PricebookEntryId, Product2Id, Quantity, TotalPrice, UnitPrice 
                                        FROM OpportunityLineItem where OpportunityId in: setOpportunityId]){

            if(mapOLI.containsKey(oli.OpportunityId)){
                mapOLI.get(oli.OpportunityId).add(oli);
            }else{
                mapOLI.put(oli.OpportunityId, new List <OpportunityLineItem> { oli });
            }
        }

        System.debug('mapOLI:-->' + mapOLI);

        /*
        if(lstQuote.size() > 0){
            insert lstQuote;

            for(Quote q : lstQuote){
                for(OpportunityLineItem oli : mapOLI.get(q.OpportunityId)){
                    lstQLI.add(new QuoteLineItem(QuoteId=q.Id, PricebookEntryId=oli.PricebookEntryId, Product2Id=oli.Product2Id,
                                                    Quantity=oli.Quantity, UnitPrice=oli.UnitPrice)
                            );
                }
            }
            System.debug('lstQLI:-->' + lstQLI);
            if(lstQLI.size() > 0)
                insert lstQLI;
        }
        */

        if(lstOrder.size() > 0){
            insert lstOrder;

            for(Order o : lstOrder){
                for(OpportunityLineItem oli : mapOLI.get(o.OpportunityId)){

                    System.debug('o.Id:-->' + o.Id);
                    System.debug('oli.PricebookEntryId:-->' + oli.PricebookEntryId);
                    System.debug('oli.Product2Id:-->' + oli.Product2Id);
                    System.debug('oli.Quantity:-->' + oli.Quantity);
                    System.debug('oli.UnitPrice:-->' + oli.UnitPrice);
                    lstOrderItem.add(new OrderItem(OrderId=o.Id, PricebookEntryId=oli.PricebookEntryId, Product__c=oli.Product2Id,
                                                    Quantity=oli.Quantity, UnitPrice=oli.UnitPrice)
                            );
                }
            }

            if(lstOrderItem.size() > 0)
                insert lstOrderItem;
        }
    }
}