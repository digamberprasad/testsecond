/**
 * Helper for OrderTrigger
 * @author Digamber Prasad
 * */
public with sharing class OrderTriggerHelper {
	
	/**
	* Method which creates Assets for given list of Orders
	* @param List<Order>
	* @return void
	* */
	public static void createAssets(List<Order> lstOrder){

		Map<Id, Order> mapOrder = new Map<Id, Order>();
		List<Asset> lstAsset = new List<Asset>();

		for(Order ord : lstOrder){
			System.debug('ord:-->' + ord.OrderNumber);
			mapOrder.put(ord.Id, ord);
		}

		for(OrderItem ordItem : [Select Id, OrderId, OriginalOrderItemId, UnitPrice, Quantity , Product__c, Product__r.Name from OrderItem where OrderId in: mapOrder.keySet()]){
			System.debug('ordItem.Product__c:-->' + ordItem.Product__c);
			System.debug('ordItem.Product__r.Name:-->' + ordItem.Product__r.Name);
			lstAsset.add(
							new Asset(Name=ordItem.Product__r.Name, Order__c=ordItem.OrderId, 
										Member__c=mapOrder.get(ordItem.OrderId).Purchasing_Member__c,
										AccountId=mapOrder.get(ordItem.OrderId).AccountId, Expiry_Date__c=System.today().addMonths(12),
										Price=ordItem.UnitPrice, Quantity=ordItem.Quantity, Status='Active', 
										PurchaseDate=mapOrder.get(ordItem.OrderId).EffectiveDate, Product2Id=ordItem.Product__c
									)

						);
		}
		System.debug('lstAsset:-->' + lstAsset);
		if(lstAsset.size() > 0)
			insert lstAsset;
		
	}

}