trigger CartItemTrigger on Cart_item__c (before insert, before update) {
for (Cart_item__c item : Trigger.new) {
        if (item.Item_List_Price__c != null && item.Quantity__c != null) {
            item.Total_Price__c = item.Item_List_Price__c * item.Quantity__c;
        }
    }
}