public without sharing class MembershipPurchaseCheckoutController {
    /**
    * Get product based upon individual member or type of group
    * @param String memberId
    * @param String groupId
    * @return List<ProductWrapper> list of productwrapper which has all the product related to individual/group
    * */
    @AuraEnabled
    public static List<ProductWrapper> getProduct(String memberId, String groupId){
        
        List<ProductWrapper> lstProductWrapper = new List<ProductWrapper>();
        String productFamily = '';
        
        if(!String.isBlank(memberId)){
            productFamily = 'Membership - Individual';
        }else{
            productFamily = 'Membership - Group';
        }

        for(PricebookEntry price : [SELECT Name, Product2Id, ProductCode, UnitPrice FROM PricebookEntry where Product2.Family =: productFamily]){
            lstProductWrapper.add(new ProductWrapper(price));
        }

        System.debug('lstProductWrapper:-->' + lstProductWrapper);
        return lstProductWrapper;

    }

    @AuraEnabled
    public static String createOpportunity(List<ProductWrapper> lstProduct, String memberId, String groupId){
        System.debug('lstProduct:-->' + lstProduct);
        System.debug('memberId:-->' + memberId);
        System.debug('groupId:-->' + groupId);
        return null;
    }

    @AuraEnabled
    public static String createPayment(String jsonSerializeProduct, String memberId, String groupId){
        
        List<ProductWrapper> lstSelectedProduct = new List<ProductWrapper>();
        List<OpportunityLineItem> lstOpptyLineItem = new List<OpportunityLineItem>();
        Id accountId;
        Double totalAmount = 0;
        String opportunityName = '';
        Set<Id> setProductId = new Set<Id>();
        Map<Id, Id> prodToPbe = new Map<Id, Id>();
        Id opptyProductRecordTypeId = BEHelper.getRecordTypeId(Opportunity.sObjectType, 'Product');

        System.debug('jsonSerializeProduct:-->' + jsonSerializeProduct);
        List<ProductWrapper> lstProduct = (List<ProductWrapper>) JSON.deserialize(jsonSerializeProduct, List<ProductWrapper>.class); 

        for(ProductWrapper prod : lstProduct){

            if(prod.isSelected && prod.quantity > 0){

                //Create opportunity and line item
                lstSelectedProduct.add(prod);
                opportunityName = opportunityName + prod.productName +'; ';
                totalAmount += prod.salesPrice;
                
                setProductId.add(prod.productId);

            }
        }

        for (PricebookEntry pbEntry : [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :setProductId AND Pricebook2.isStandard=true]) {
            prodToPbe.put(pbEntry.Product2Id, pbEntry.Id);
        }

        Id contactId;

        if(!String.isBlank(memberId)){
            Contact c = [Select Id, Name, AccountId from Contact where BE_Membership_Number__c =: String.valueOf(memberId)];
            accountId = c.AccountId;
            contactId = c.Id;
        }

        Opportunity oppty = new Opportunity();

        if(lstSelectedProduct.size() > 0){
            oppty.Name = opportunityName;
            oppty.RecordTypeId = opptyProductRecordTypeId;
            oppty.AccountId = accountId;
            oppty.Purchasing_Member__c = contactId;
            oppty.StageName = 'Confirmed';
            oppty.CloseDate = System.today();
        }

        insert oppty;

        for(ProductWrapper prod : lstSelectedProduct){
            lstOpptyLineItem.add(new OpportunityLineItem(Quantity=prod.quantity, UnitPrice=prod.salesPrice, OpportunityId=oppty.Id,
                                            PricebookEntryId=prodToPbe.get(prod.productId), ServiceDate=System.today()));
        }
        System.debug('lstOpptyLineItem:-->' + lstOpptyLineItem);

        if(lstOpptyLineItem.size() > 0)
            insert lstOpptyLineItem;

        oppty.Is_Order_Created__c = true;   //need clean up later
        update oppty;

        Set<Id> setAccountId = new Set<Id>();
        setAccountId.add('0014E00000948V4');


        String worldpayPaymentUrl = '';
        //Contact member = (Contact)(PAYBASE2.Util.getSObjects(setMemberId )[0]);
        Account member = (Account)(PAYBASE2.Util.getSObjects(setAccountId )[0]);
        PAYBASE2__Payment__c payment = new PAYBASE2__Payment__c();
        SObject mapping = PAYCP2.CardPaymentFieldMappings.getInstance().getFieldMappingForId(member.id);
        PAYCP2.BaseNewCardPaymentController.populateCardPayment( payment, member, mapping, new Map<String, String>(), false);
        payment.paybase2__amount__c = totalAmount;
        payment.PAYCP2__Payment_Description__c = 'DESCRIPTION';
        payment.RecordTypeId = PAYBASE2__Payment__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('Worldpay').getRecordTypeId();
        payment.PAYCP2__Gateway_Id__c = PAYLIC1.Configurations.get('Worldpay:Payment_Installation_Id');
        insert payment;

        //worldpayPaymentUrl = PAYWPCP1.WorldpayPaymentExtension.calculatePaymentUrl(Payment, '').getUrl();
        update payment;

        System.debug('worldpayPaymentUrl:-->' + worldpayPaymentUrl);
        return worldpayPaymentUrl;
    }

    public class ProductWrapper {

        @AuraEnabled
        public Boolean isSelected { get; set; }
        @AuraEnabled
        public String productId { get; set; }
        @AuraEnabled
        public String productName { get; set; }
        @AuraEnabled
        public Double salesPrice { get; set; }
        @AuraEnabled
        public Date closeDate { get; set; }
        @AuraEnabled
        public Integer quantity { get; set; }

        public ProductWrapper(PricebookEntry price){
            this.isSelected = false;
            this.productId = price.Product2Id;
            this.productName = price.Name;
            this.salesPrice = price.UnitPrice;
            this.closeDate = System.today();
            this.quantity = 1;
        }

    }
}