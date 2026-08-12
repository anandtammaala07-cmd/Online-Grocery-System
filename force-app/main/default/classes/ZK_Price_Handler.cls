/**
* @File Name : ZK_Price_Handler.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : September 20, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 20, 2025 |   | Initial Version
**/


public without sharing class ZK_Price_Handler {
    public static void updatePrice(List<PricebookEntry> newEntries) {
        
        Map<Id, Product2> productsToUpdate = new Map<Id, Product2>();
        
        for (PricebookEntry entry : newEntries) {
            
            if (entry.Product2Id != null) {
                Product2 prod = new Product2(
                    Id = entry.Product2Id,
                    Price__c = entry.UnitPrice
                );
                productsToUpdate.put(prod.Id, prod);
            }
        }
        
        if (!productsToUpdate.isEmpty()) {
            try {
                update productsToUpdate.values();
            } catch(DmlException e) {
                System.debug('Error updating Product2 records: ' + e.getMessage());
            }
        }
    }
}